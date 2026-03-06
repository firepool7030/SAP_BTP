CLASS lhc_PIRHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PIRHeader RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE PIRHeader.

    METHODS earlynumbering_cba_PIRItem FOR NUMBERING
      IMPORTING entities FOR CREATE PIRHeader\_piri.

    METHODS predictNextMonthPIR FOR MODIFY
      IMPORTING keys FOR ACTION PIRHeader~predictNextMonthPIR RESULT result.

ENDCLASS.

CLASS lhc_PIRHeader IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  " PIR 헤더번호 CREATE 넘버레인지
  METHOD earlynumbering_create.

    DATA: lv_pirnr TYPE ztckpirh-pirnr.

    LOOP AT entities INTO DATA(ls_entity). " RAP는 대용량 처리가 기본이기 때문에 모든 데이터를 테이블로서 처리한다.

      TRY.
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

        CATCH cx_nr_object_not_found INTO DATA(lx_no_obj_found).
          " 오브젝트 못 찾았을 때 실패처리
          APPEND VALUE #(
            %cid = ls_entity-%cid
            %key = ls_entity-%key
          ) TO failed-pirheader.
          CONTINUE.

        CATCH cx_number_ranges INTO DATA(lx_number_ranges).
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
          CONTINUE.

      ENDTRY.

      lv_pirnr = lv_number+10(10).

      APPEND VALUE #(
        %cid  = ls_entity-%cid
        %is_draft = ls_entity-%is_draft
        pirnr = lv_pirnr
      ) TO mapped-pirheader.

    ENDLOOP.


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

      DATA lv_final_max TYPE i.

      IF lv_max_iteno > lv_max_draft_iteno.
        lv_final_max = lv_max_iteno.
      ELSE.
        lv_final_max = lv_max_draft_iteno.
      ENDIF.

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
    DATA: ngrok_url TYPE string VALUE 'https://1518-175-196-202-23.ngrok-free.app'.

    " HTTP 메세지 통신용 변수
    DATA: lo_client     TYPE REF TO if_web_http_client,
          lo_request    TYPE REF TO if_web_http_request,
          lo_response   TYPE REF TO if_web_http_response,
          lo_dest       TYPE REF TO if_http_destination,
          lx_web_error  TYPE REF TO cx_web_http_client_error,    " 파이썬 서버에 도달 조차 못할때 나오는 에러 잡는 변수
          lx_dest_error TYPE REF TO cx_http_dest_provider_error. "

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
    TRY.

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

        " 6-1.예외처리: 서버 연결 에러
        CATCH cx_web_http_client_error INTO lx_web_error.

          " 1. 에러 메시지 텍스트 추출
          DATA(lv_web_err_text) = lx_web_error->get_text( ).

          " 2. UI로 에러 던지기 (REPORTED 구조체에 APPEND)
          APPEND VALUE #(
            %msg    = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error " 에러 아이콘(빨간색 X) 표시
                      text     = CONV #( lv_web_err_text )
                    )
            %global = if_abap_behv=>mk-on " 특정 라인이 아닌 글로벌(전체 화면) 에러로 띄움
          ) TO reported-pirheader.

        " 6-2. 예외처리: URL 변환 에러
        CATCH cx_http_dest_provider_error INTO lx_dest_error.
          DATA(lv_dest_err_text) = lx_dest_error->get_text( ).

          APPEND VALUE #(
            %msg    = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = CONV #( lv_dest_err_text )
                    )
            %global = if_abap_behv=>mk-on
          ) TO reported-pirheader.

    ENDTRY.

    " 6-3.기타 예외: 응답 코드가 200(성공)이 아닐 때 처리
    IF lv_status-code <> 200.
      APPEND VALUE #(
        %msg    = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = CONV #( |서버 오류 발생: { lv_status-code } { lv_status-reason }| )
                  )
        %global = if_abap_behv=>mk-on
      ) TO reported-pirheader.
      RETURN. " 실패했으므로 로직 종료
    ENDIF.

    " =====================================================================
    "   [200] -> JSON 데이터 파싱 후 테이블에 저장
    " =====================================================================

    " 1. 수신된 JSON 데이터 타입 변환
    TYPES: BEGIN OF ts_result,
             matnr TYPE zeck_matnr,
             aiqty TYPE zeck_aiqty,
             cnflv TYPE zeck_cnflv,
           END OF ts_result,
           tt_result TYPE STANDARD TABLE OF ts_result WITH DEFAULT KEY,

           BEGIN OF ts_response,
             status  TYPE string,
             results TYPE tt_result,
           END OF ts_response.

    DATA: ls_api_response TYPE ts_response.

    "2. JSON Deserialization을 통해 (문자열 -> ABAP 구조체로 변환)
    /ui2/cl_json=>deserialize(
      EXPORTING json = lv_response
      CHANGING  data = ls_api_response
    ).

    " =====================================================================
    "   RAP EML을 사용한 생성 (Draft Deep Create) - Static Action 버전
    " =====================================================================

    "3. EML처리를 위한 테이블 선언
    DATA: lt_create_head TYPE TABLE FOR CREATE ZIVWJCK_PIRH\\PIRHeader,
          lt_create_item TYPE TABLE FOR CREATE ZIVWJCK_PIRH\\PIRHeader\_piri,
          ls_create_item LIKE LINE OF lt_create_item.

    "4. 헤더 데이터 생성
    append value #(
      %cid      = 'CID_HEADER'
      %is_draft = if_abap_behv=>mk-on "Draft 모드로 설정
    ) TO lt_create_head.

    "5. 아이템 데이터 세팅
    ls_create_item-%cid_ref  = 'CID_HEADER'.
    ls_create_item-%is_draft = if_abap_behv=>mk-on.

    DATA(lv_iteno) = 1. "아이템 번호 1부터 시작

    LOOP AT ls_api_response-results into data(ls_results).
      append value #(
        %cid      = |CID_ITEM_{ lv_iteno }|
        %is_draft = if_abap_behv=>mk-on
        iteno     = lv_iteno
        matnr     = ls_results-matnr
        aiqty     = ls_results-aiqty
        cnflv     = ls_results-cnflv
        %control  = VALUE #( iteno = if_abap_behv=>mk-on
                             matnr = if_abap_behv=>mk-on
                             aiqty = if_abap_behv=>mk-on
                             cnflv = if_abap_behv=>mk-on )
        ) TO ls_create_item-%target.

      lv_iteno += 1.

    ENDLOOP.

    append ls_create_item to lt_create_item.

    " 7. MODIFY ENTITIES 실행 (로컬 모드)
    MODIFY ENTITIES OF ZIVWJCK_PIRH IN LOCAL MODE
      ENTITY PIRHeader
        CREATE FROM lt_create_head
      CREATE BY \_piri
        FROM lt_create_item
      MAPPED   DATA(ls_mapped)
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    " 8. 생성된 결과 및 에러를 UI로 전달 (중요)
    " = 대신 APPEND LINES OF를 써야 기존에 담겨있던 다른 에러가 덮어씌워져 날아가는 것을 방지할 수 있습니다.
    APPEND LINES OF ls_mapped-pirheader   TO mapped-pirheader.
    APPEND LINES OF ls_failed-pirheader   TO failed-pirheader.
    APPEND LINES OF ls_reported-pirheader TO reported-pirheader.

    " 9-1. 생성된 임시 키(ls_mapped)를 바탕으로 생성된 헤더 데이터를 다시 읽어옵니다.
    READ ENTITIES OF ZIVWJCK_PIRH IN LOCAL MODE
      ENTITY PIRHeader
        ALL FIELDS WITH CORRESPONDING #( ls_mapped-pirheader )
      RESULT DATA(lt_read_head).

    " 9-2. 읽어온 데이터를 액션의 반환값(result)과 성공 메시지(reported)에 담아줍니다.

    " [수정 부분] 1. Fiori UI가 버튼 클릭 시 보낸 Action Request의 %cid를 읽어옵니다.
    DATA(lv_action_cid) = VALUE #( keys[ 1 ]-%cid OPTIONAL ).

    LOOP AT lt_read_head INTO DATA(ls_read_head).

      " [수정 부분] 2. result에 %cid와 %tky를 반드시 포함해야 Fiori가 응답을 인식합니다.
      APPEND VALUE #(
        %cid   = lv_action_cid      " UI 요청과 결과를 연결해주는 핵심 키
        %param = ls_read_head       " 반환할 실제 데이터 ($self)
      ) TO result.

      " 생성된 문서에 바인딩된 성공 메시지 (리스트 화면 갱신 시 팝업으로 나타남)
      APPEND VALUE #(
        %tky = ls_read_head-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-success
                 text     = CONV #( |드래프트가 성공적으로 생성되었습니다.| )
               )
      ) TO reported-pirheader.

    ENDLOOP.

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
    READ ENTITIES OF zivwjck_pirh IN LOCAL MODE
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
    READ ENTITIES OF zivwjck_pirh IN LOCAL MODE
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
    READ ENTITIES OF zivwjck_pirh IN LOCAL MODE
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
