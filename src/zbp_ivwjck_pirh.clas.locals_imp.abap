CLASS lhc_PIRHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PIRHeader RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE PIRHeader.

    METHODS earlynumbering_cba_PIRItem FOR NUMBERING
      IMPORTING entities FOR CREATE PIRHeader\_PIRI.

    METHODS predictNextMonthPIR FOR MODIFY
    IMPORTING keys FOR ACTION PIRHeader~predictNextMonthPIR RESULT result.

ENDCLASS.

CLASS lhc_PIRHeader IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  " PIR 헤더번호 CREATE 넘버레인지
  METHOD earlynumbering_create.

    DATA: lv_pirnr type ztckpirh-pirnr.

    loop at entities into data(ls_entity). " RAP는 대용량 처리가 기본이기 때문에 모든 데이터를 테이블로서 처리한다.

      try.
        " 1. 자동 채번을 사용해서
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZNR_PIRH'
            quantity          = 1
          IMPORTING
            number            = DATA(lv_number)
            returncode        = DATA(lv_return_code)
            returned_quantity = DATA(lv_return_qty)
        ).

        CATCH cx_nr_object_not_found into DATA(lx_no_obj_found).
          " 오브젝트 못 찾았을 때 실패처리
          APPEND VALUE #(
            %cid = ls_entity-%cid
            %key = ls_entity-%key
          ) TO failed-pirheader.
          continue.

        CATCH cx_number_ranges into DATA(lx_number_ranges).
          " 사용자에게 에러 메시지 전달
          APPEND VALUE #(
            %cid = ls_entity-%cid
            %key = ls_entity-%key
            %msg = lx_number_ranges
          ) TO reported-pirheader.
          " 해당 건은 실패 처리
          APPEND VALUE #(
            %cid = ls_entity-%cid
            %key = ls_entity-%key
          ) TO failed-pirheader.
          continue.

      endtry.

      lv_pirnr = lv_number+10(10).

      APPEND VALUE #(
        %cid  = ls_entity-%cid
        %is_draft = ls_entity-%is_draft
        pirnr = lv_pirnr
      ) TO mapped-pirheader.

    endloop.


  ENDMETHOD.

  " PIR 아이템번호 CREATE 넘버레인지
  METHOD earlynumbering_cba_PIRItem.

    " 1. 부모(Header) 단위로 Loop (보통 1건)
    LOOP AT entities INTO DATA(ls_entity_h).

      " 2. 해당 PIR 문서번호(pirnr)에 이미 저장된 아이템 중 가장 큰 번호 찾기
      SELECT MAX( iteno )
        FROM ztckpiri
        WHERE pirnr = @ls_entity_h-pirnr
        INTO @DATA(lv_max_iteno).

      SELECT MAX( iteno )
        FROM ztckwj_piri_d
        WHERE pirnr = @ls_entity_h-pirnr
         INTO @DATA(lv_max_draft_iteno).

      DATA lv_final_max type i.

      if lv_max_iteno > lv_max_draft_iteno.
        lv_final_max = lv_max_iteno.
      else.
        lv_final_max = lv_max_draft_iteno.
      endif.

      " 3. 새로 생성하려는 자식(Item)들 Loop
      LOOP AT ls_entity_h-%target INTO DATA(ls_entity_i).

        " 번호 10단위 증가 (10, 20, 30...)
        lv_final_max = lv_final_max + 1.

        " 4. MAPPED 채우기 (아이템용)
        APPEND VALUE #(
          %cid      = ls_entity_i-%cid
          %key      = ls_entity_i-%key
          %is_draft = ls_entity_i-%is_draft
          " 실제 DB Key Mapping
          pirnr     = ls_entity_h-pirnr  " 부모 번호
          iteno     = lv_final_max       " 방금 만든 자식 번호
        ) TO mapped-piritem.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  " SO 데이터 기반 PIR 예측 메서드
  METHOD predictNextMonthPIR.

    " ngrok api url 데이터로 정의 (항상 가변적이니 계속 바꿔주자)
    DATA: ngrok_url TYPE string VALUE 'https://2177-2001-e60-8805-4b10-50a1-f7dd-6ebd-32cb.ngrok-free.app'.

    " HTTP 메세지 통신용 변수
    DATA: lo_client         type ref to if_web_http_client,
          lo_request        type ref to if_web_http_request,
          lo_response       type ref to if_web_http_response,
          lo_dest           type ref to if_http_destination,
          lx_web_error      type ref to cx_web_http_client_error,   " 파이썬 서버에 도달 조차 못할때 나오는 에러 잡는 변수
          lx_dest_error     type ref to cx_http_dest_provider_error."

    TYPES: BEGIN OF ts_root,
             history_items TYPE STANDARD TABLE OF ztcksh WITH DEFAULT KEY,
           END OF ts_root.

    DATA: ls_request_data TYPE ts_root.

    " ZTCKSH 테이블 전체 조회 (SELECT)
    SELECT *
      FROM ztcksh
      INTO TABLE @ls_request_data-history_items.

    " 데이터가 없으면 메서드 종료
    IF ls_request_data-history_items IS INITIAL.
      RETURN.
    ENDIF.

    " JSON 형식으로 데이터 수정
    DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_request_data ).

    " 통신 시도
    try.

      " 1. 문자열 URL을 Destination 객체로 변환
      lo_dest = cl_http_destination_provider=>create_by_url( ngrok_url ).

      " 2. 변환된 객체를 사용해서 클라이언트 객체 생성
      lo_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

      " 3. 요청 객체값 설정
      lo_request = lo_client->get_http_request( ).
      lo_request->set_uri_path( '/predict' ). " 사용할 API의 엔드포인트 설정
      lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ). " 헤더에 데이터 내용물 타입이 JSON이라고 선언

      " 4. 객체에 데이터 넣고 서버에 전송
      lo_request->set_text( lv_json ). " 보내줄 더미데이터 입력 -> 나중에 수정 필요!
      lo_response = lo_client->execute( i_method = if_web_http_client=>post ). " 위에 더미 데이터를 넣고 python에 post하기

      " 5. 서버에 대한 응답 변수에 저장
      DATA(lv_status) = lo_response->get_status( ).
      DATA(lv_response) = lo_response->get_text( ).

    " 예외처리 1: 서버 연결 에러
    catch cx_web_http_client_error into lx_web_error.

    " 예외처리 2: URL 변환 에러
    catch cx_http_dest_provider_error into lx_dest_error.

    endtry.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_PIRItem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateAIConf FOR VALIDATE ON SAVE
      IMPORTING keys FOR PIRItem~validateAIConf.

    METHODS validateQuantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR PIRItem~validateQuantity.

    METHODS validateUnit FOR VALIDATE ON SAVE
      IMPORTING keys FOR PIRItem~validateUnit.

ENDCLASS.

CLASS lhc_PIRItem IMPLEMENTATION.

  " 1. 수량 4종 (Aiqty, Plnmg, Plqty, Urqty) 0보다 큰지 검사
  METHOD validateQuantity.
    " 화면의 최신 값을 읽어옵니다.
    READ ENTITIES OF ZIVWJCK_PIRH IN LOCAL MODE
      ENTITY PIRItem
      FIELDS ( Aiqty Plnmg Plqty Urqty )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_PIRItem).

    LOOP AT lt_PIRItem INTO DATA(ls_PIRItem).

      " 1) AI 예측 수량 검사
      IF ls_PIRItem-Aiqty <= 0.
        APPEND VALUE #( %tky = ls_PIRItem-%tky ) TO failed-PIRItem.
        APPEND VALUE #( %tky = ls_PIRItem-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'AI 예측 수량은 0보다 커야 합니다.' )
                        %element-Aiqty = if_abap_behv=>mk-on ) TO reported-PIRItem.
      ENDIF.

      " 2) 계획 수량 검사
      IF ls_PIRItem-Plnmg <= 0.
        APPEND VALUE #( %tky = ls_PIRItem-%tky ) TO failed-PIRItem.
        APPEND VALUE #( %tky = ls_PIRItem-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = '계획 수량은 0보다 커야 합니다.' )
                        %element-Plnmg = if_abap_behv=>mk-on ) TO reported-PIRItem.
      ENDIF.

      " 3) 생산 수량 검사
      IF ls_PIRItem-Plqty <= 0.
        APPEND VALUE #( %tky = ls_PIRItem-%tky ) TO failed-PIRItem.
        APPEND VALUE #( %tky = ls_PIRItem-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = '생산 수량은 0보다 커야 합니다.' )
                        %element-Plqty = if_abap_behv=>mk-on ) TO reported-PIRItem.
      ENDIF.

      " 4) 미확정 수량 검사
      IF ls_PIRItem-Urqty <= 0.
        APPEND VALUE #( %tky = ls_PIRItem-%tky ) TO failed-PIRItem.
        APPEND VALUE #( %tky = ls_PIRItem-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = '미확정 수량은 0보다 커야 합니다.' )
                        %element-Urqty = if_abap_behv=>mk-on ) TO reported-PIRItem.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

" 2. 단위 검사
  METHOD validateUnit.
    READ ENTITIES OF ZIVWJCK_PIRH IN LOCAL MODE
      ENTITY PIRItem
      FIELDS ( Meins )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_PIRItem).

    LOOP AT lt_PIRItem INTO DATA(ls_item).
      CHECK ls_item-Meins IS NOT INITIAL.

      " T006 대신 I_UnitOfMeasure CDS View 사용
      SELECT SINGLE UnitOfMeasure
        FROM I_UnitOfMeasure
        WHERE UnitOfMeasure = @ls_item-Meins
        INTO @DATA(lv_dummy).

      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-piritem.
        APPEND VALUE #( %tky = ls_item-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = '유효하지 않은 단위입니다.' )
                        %element-Meins = if_abap_behv=>mk-on ) TO reported-piritem.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " 3. 신뢰도 검사
  METHOD validateAIConf.
    READ ENTITIES OF ZIVWJCK_PIRH IN LOCAL MODE
      ENTITY PIRItem
      FIELDS ( Cnflv )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_PIRItem).

    LOOP AT lt_PIRItem INTO DATA(ls_item).
      IF ls_item-Cnflv < 0 OR ls_item-Cnflv > 100.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-piritem.
        APPEND VALUE #( %tky = ls_item-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = '신뢰도는 0~100 사이여야 합니다.' )
                        %element-Cnflv = if_abap_behv=>mk-on ) TO reported-piritem.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
