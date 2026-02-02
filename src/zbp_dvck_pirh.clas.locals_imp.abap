** CLASS 정의 **********************************************************************
CLASS lhc_PIR_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PIR_Header RESULT result.
    METHODS valid_check FOR VALIDATE ON SAVE
      IMPORTING keys FOR pir_header~valid_check.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE pir_header.
ENDCLASS.

CLASS lhc_PIR_Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE pir_header\_items.
ENDCLASS.
***********************************************************************************

** PIR Header 구현부 **
CLASS lhc_PIR_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  " 넘버레인지 구현
  METHOD earlynumbering_create.

    LOOP AT entities INTO DATA(ls_entity).

      IF ls_entity-pirnr IS NOT INITIAL.
        APPEND VALUE #( %cid  = ls_entity-%cid
                        %is_draft = ls_entity-%is_draft
                        pirnr = ls_entity-pirnr ) TO mapped-pir_header.
        CONTINUE.
      ENDIF.

      TRY.
          cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZNR_PIR_JY'
            quantity          = 1
          IMPORTING
            number            = DATA(lv_number) "CHAR 20
            returncode        = DATA(lv_ret_code)
            returned_quantity = DATA(lv_ret_qty)
          ).

          " 문자열 템플릿 이용해서 0 제거 (00..0010 -> 10)
          DATA(lv_convert_nr) = |{ lv_number ALPHA = OUT }|.
          " 생성된 번호를 프레임워크의 mapped 테이블에 등록
          APPEND VALUE #( %cid = ls_entity-%cid
                          %is_draft = ls_entity-%is_draft
                          pirnr = lv_convert_nr ) TO mapped-pir_header.

          " 실패 시 에러처리
        CATCH cx_nr_object_not_found INTO DATA(lx_not_found).
          APPEND VALUE #( %cid = ls_entity-%cid
                          %is_draft = ls_entity-%is_draft ) TO failed-pir_header.
          APPEND VALUE #( %cid = ls_entity-%cid
                          %is_draft = ls_entity-%is_draft
                          %msg = lx_not_found   ) TO reported-pir_header.
        CATCH cx_number_ranges INTO DATA(lx_number_ranges).
          APPEND VALUE #( %cid = ls_entity-%cid
                          %is_draft = ls_entity-%is_draft ) TO failed-pir_header.
          APPEND VALUE #( %cid = ls_entity-%cid
                          %is_draft = ls_entity-%is_draft
                          %msg = lx_number_ranges ) TO reported-pir_header.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  " 유효성 체크
  METHOD valid_check.

    READ ENTITIES OF zdvck_pirh IN LOCAL MODE
      ENTITY PIR_Header
        FIELDS ( werks )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    " 플랜트가 비어있는 경우 메세지 표시
    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).

*      APPEND VALUE #( %tky = <header>-%tky ) TO reported-pir_header.

      IF <header>-werks IS INITIAL.
        " 저장을 막는 로직
        APPEND VALUE #( %tky = <header>-%tky ) TO failed-pir_header.
        " 사용자에게 보여줄 메세지
        APPEND VALUE #( %tky = <header>-%tky
                        %msg = new_message_with_text(
                                 text = '플랜트 입력하세요;'
                                 severity = if_abap_behv_message=>severity-error )
                        %element-werks = if_abap_behv=>mk-on ) TO reported-pir_header.

      ELSEIF <header>-werks IS NOT INITIAL.
        " 유효하지 않은 값일 때 오류검출
        IF <header>-werks <> '1000' AND <header>-werks <> '2000'.
          " 저장을 막는 로직
          APPEND VALUE #( %tky = <header>-%tky ) TO failed-pir_header.
          " 사용자에게 보여줄 메세지
          APPEND VALUE #( %tky = <header>-%tky
                          %msg = new_message_with_text(
                                   text = '유효하지 않은 플랜트입니다'
                                   severity = if_abap_behv_message=>severity-error )
                          %element-werks = if_abap_behv=>mk-on ) TO reported-pir_header.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
***********************************************************************************

** PIR Item 구현부 **
CLASS lhc_PIR_Item IMPLEMENTATION.
  METHOD earlynumbering_create.

    " 1. 헤더 단위 루프
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_header>).

      SELECT MAX( iteno )
        FROM ztckpiri_d
       WHERE pirnr = @<ls_header>-pirnr
        INTO @DATA(lv_max_item_no).

      IF sy-subrc = 0.
        DATA(lv_next_item_no) = lv_max_item_no.
      ENDIF.

      " 2. 아이템 단위 루프
      LOOP AT <ls_header>-%target ASSIGNING FIELD-SYMBOL(<ls_item>).

        IF <ls_item>-iteno IS NOT INITIAL.
          APPEND VALUE #( %cid      = <ls_item>-%cid
                          %is_draft = <ls_item>-%is_draft
                          pirnr     = <ls_header>-pirnr
                          iteno     = <ls_item>-iteno ) TO mapped-pir_item.
          CONTINUE.
        ENDIF.

        lv_next_item_no += 1.

        APPEND VALUE #( %cid      = <ls_item>-%cid
                        %is_draft = <ls_item>-%is_draft
                        pirnr     = <ls_header>-pirnr
                        iteno     = lv_next_item_no ) TO mapped-pir_item.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
