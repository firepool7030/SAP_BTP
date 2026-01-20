CLASS zcwj_pirh_number_range DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcwj_pirh_number_range IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " PIRNR Number Range Object 생성
    data: nr_attribute  type cl_numberrange_objects=>nr_attribute,
          obj_text      type cl_numberrange_objects=>nr_obj_text,
          lv_returncode type cl_numberrange_objects=>nr_returncode,
          lv_errors     type cl_numberrange_objects=>nr_errors.

    nr_attribute-buffer = 'X'.
    nr_attribute-object = 'ZNR_PIRH'.
    nr_attribute-domlen = 'ZDCK_PIRNR'.
    nr_attribute-percentage = 10.
    nr_attribute-devclass = 'ZCK_PROJECT'.

    obj_text-langu = 'E'.
    obj_text-object = 'ZNR_PIRH'.
    obj_text-txt = 'Createing PIRH Number Range'.
    obj_text-txtshort = 'PIRH NUMBER'.

    try.
      cl_numberrange_objects=>create(
        EXPORTING
          attributes = nr_attribute
          obj_text   = obj_text
        IMPORTING
          errors     = lv_errors
          returncode = lv_returncode
      ).

      " 생성되었는지 콘솔에 확인
      IF lv_returncode IS INITIAL AND lv_errors IS INITIAL.
          out->write( '1. Object Creation : [SUCCESS] (Return code is empty)' ).
      ELSE.
        out->write( |1. Object Creation : [FAILED] ReturnCode: { lv_returncode }| ).
      ENDIF.

      CATCH cx_number_ranges
        into data(lx_number_range).
        out->write( |Object Error: { lx_number_range->get_text( ) } | ).

    endtry.


    " PIRNR Number Range Interval 생성
    DATA: nrt_interval type cl_numberrange_intervals=>nr_interval,
          nrs_interval like line of nrt_interval.

    nrs_interval-subobject = ''.
    nrs_interval-nrrangenr = '01'.
    nrs_interval-fromnumber = '1000000000'.
    nrs_interval-tonumber = '9999999999'.
    nrs_interval-procind = 'I'.

    append nrs_interval to nrt_interval.

    try.
      call method cl_numberrange_intervals=>create(
        EXPORTING
          interval  = nrt_interval
          object    = 'ZNR_PIRH'
        IMPORTING
          error     = DATA(lv_error)
          error_inf = DATA(lv_error_info)
          error_iv  = DATA(lv_error_iv)
      ).
      " 생성되었는지 콘솔에 확인
      IF lv_error IS INITIAL.
        out->write( '2. Interval Creation : [SUCCESS] (Error code is empty)' ).
      ELSE.
        out->write( |2. Interval Creation : [FAILED] Error Code: { lv_error }| ).
      ENDIF.

      CATCH cx_nr_object_not_found
        into DATA(lx_no_obj_found).
        out->write( |Interval Error: Object not found| ).
      CATCH cx_number_ranges
        into DATA(cx_number_ranges).
        out->write( |Interval Error: { cx_number_ranges->get_text( ) }| ).

    endtry.

  ENDMETHOD.

ENDCLASS.
