CLASS zcl_pirnr_test_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    interfaces if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_pirnr_test_class IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

    DATA: lv_number     TYPE cl_numberrange_runtime=>nr_number,
          lv_returncode TYPE cl_numberrange_runtime=>nr_returncode,
          lv_quantity   TYPE cl_numberrange_runtime=>nr_quantity.

    out->write( '--- 넘버레인지 채번 테스트 시작 ---' ).

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'          " 인터벌 번호
            object            = 'ZNR_PIRH'    " 오브젝트 이름
            quantity          = 1
          IMPORTING
            number            = lv_number
            returncode        = lv_returncode
            returned_quantity = lv_quantity
        ).

        " 결과 출력
        out->write( |1. 채번된 번호: { lv_number+10(10) }| ).
        out->write( |2. 리턴 코드  : { lv_returncode } (0이어야 정상)| ).

        IF lv_returncode IS NOT INITIAL.
             out->write( '>>> [오류 분석] <<<' ).
             CASE lv_returncode.
               WHEN '1'. out->write( '- 원인: 인터벌 01이 존재하지 않습니다.' ).
               WHEN '2'. out->write( '- 원인: ZNR_PIRH 오브젝트가 없습니다.' ).
               WHEN '3'. out->write( '- 원인: 락(Lock) 문제 등 기술적 오류.' ).
               WHEN OTHERS. out->write( '- 원인: 알 수 없는 오류' ).
             ENDCASE.
        ELSE.
             out->write( '>>> [성공] 번호가 정상적으로 생성되었습니다.' ).
        ENDIF.

      CATCH cx_nr_object_not_found.
        out->write( '[Exception] 오브젝트를 찾을 수 없습니다.' ).
      CATCH cx_number_ranges INTO DATA(lx_err).
        out->write( |[Exception] 에러 발생: { lx_err->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
