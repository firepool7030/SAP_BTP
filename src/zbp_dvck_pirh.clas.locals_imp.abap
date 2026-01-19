CLASS lhc_PIR_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PIR_Header RESULT result.

ENDCLASS.

CLASS lhc_PIR_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
*    " 인스턴스(행)별 권한: 수정(Update)과 삭제(Delete) 버튼 활성화
*    LOOP AT keys INTO DATA(ls_key).
*      APPEND VALUE #( %tky = ls_key-%tky
*                      %update = if_abap_behv=>auth-allowed
*                      %delete = if_abap_behv=>auth-allowed
*                      ) TO result.
*    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
