CLASS lhc_PIRHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PIRHeader RESULT result.

*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING REQUEST requested_authorizations FOR PIRHeader RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE PIRHeader.

    METHODS earlynumbering_cba_Piri FOR NUMBERING
      IMPORTING entities FOR CREATE PIRHeader\_Piri.

ENDCLASS.

CLASS lhc_PIRHeader IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

*  METHOD get_global_authorizations.
*
*  ENDMETHOD.

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

      " MAPPED 채우기
      " Fiori 화면의 임시 ID(%cid)와 DB ID를 연결해주는 과정
      lv_pirnr = lv_number+10(10).

      APPEND VALUE #(
        %cid  = ls_entity-%cid
        pirnr = lv_pirnr
      ) TO mapped-pirheader.

    endloop.


  ENDMETHOD.

  METHOD earlynumbering_cba_Piri.

    DATA: lv_max_iteno TYPE ztckpiri-iteno.

    " 1. 부모(Header) 단위로 Loop (보통 1건)
    LOOP AT entities INTO DATA(ls_entity_h).

      " 2. 해당 PIR 문서번호(pirnr)에 이미 저장된 아이템 중 가장 큰 번호 찾기
      SELECT MAX( iteno )
        FROM ztckpiri
        WHERE pirnr = @ls_entity_h-pirnr
        INTO @lv_max_iteno.

      " 3. 새로 생성하려는 자식(Item)들 Loop
      LOOP AT ls_entity_h-%target INTO DATA(ls_entity_i).

        " 번호 10단위 증가 (10, 20, 30...)
        lv_max_iteno = lv_max_iteno + 1.

        " 4. MAPPED 채우기 (아이템용)
        APPEND VALUE #(
          %cid      = ls_entity_i-%cid
          %key      = ls_entity_i-%key

          " 실제 DB Key Mapping
          pirnr     = ls_entity_h-pirnr  " 부모 번호
          iteno     = lv_max_iteno       " 방금 만든 자식 번호
        ) TO mapped-piritem.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
