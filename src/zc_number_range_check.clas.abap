CLASS zc_number_range_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zc_number_range_check IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: lt_intervals TYPE cl_numberrange_intervals=>nr_interval.

    " 인터벌 정보 읽기
    cl_numberrange_intervals=>read(
      EXPORTING
        object    = 'ZNR_PIR_JY'
        subobject = ''
      IMPORTING
        interval  = lt_intervals
    ).

    IF lt_intervals IS INITIAL.
      out->write( '조회 결과: 인터벌이 존재하지 않습니다! (생성 실패 상태)' ).
    ELSE.
      LOOP AT lt_intervals INTO DATA(ls_iv).
        out->write( |구간번호: { ls_iv-nrrangenr }| ).
        out->write( |시작번호: { ls_iv-fromnumber }| ).
        out->write( |종료번호: { ls_iv-tonumber }| ).
        out->write( |현재번호(Status): { ls_iv-nrlevel }| ). " <-- 여기서 현재 어디까지 채번됐는지 확인 가능
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
