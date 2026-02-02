CLASS zc_pirh_nuber_range DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zc_pirh_nuber_range IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    "Number Range Object 생성
    DATA : nr_attribute  TYPE cl_numberrange_objects=>nr_attribute,
           obj_text      TYPE cl_numberrange_objects=>nr_obj_text,
           lv_returncode TYPE cl_numberrange_objects=>nr_returncode,
           lv_errors     TYPE cl_numberrange_objects=>nr_errors.

    nr_attribute-buffer = 'X'.               " 버퍼링 기능 활성화
    nr_attribute-object = 'ZNR_PIR_JY'.      " Number Range Object Name
    nr_attribute-domlen = 'ZDCK_PIRNR'.      " 사용할 Domain
    nr_attribute-percentage = 10.            " 경고 퍼센트
    nr_attribute-devclass = 'ZCK_PROJECT'.   " 개발 클래스

    obj_text-langu = 'E'.
    obj_text-object = 'ZNR_PIR_JY'.          " Object Name
    obj_text-txt = 'PIR Number Range'.       " Long Text
    obj_text-txtshort = 'Number Range'.      " Short Text


    TRY.
        cl_numberrange_objects=>create(      " Number Range Object 생성
        EXPORTING
            attributes = nr_attribute
            obj_text   = obj_text
        IMPORTING
            errors     = lv_errors
            returncode = lv_returncode ).

        " 성공 시 메시지 출력
        out->write( |Number Range Object { nr_attribute-object } created successfully.| ).

      CATCH cx_number_ranges INTO DATA(lx_number_range).
        " 실패 시 메시지 출력
        out->write( |Error creating Object: { lx_number_range->get_text( ) }| ).

    ENDTRY.


    "Interval Object 생성
    DATA: nrt_interval TYPE cl_numberrange_intervals=>nr_interval,
          nrs_interval LIKE LINE OF nrt_interval.

    nrs_interval-subobject   = ''.
    nrs_interval-nrrangenr   = '01'.          " Number Range 간격(Interval) 번호
    nrs_interval-fromnumber  = '1000000000'.  " 시작번호
    nrs_interval-tonumber    = '9999999999'.  " 종료번호
    nrs_interval-procind     = 'I'.           " Insert의 약자, 새로운 구간 추가한다는 표시
    APPEND nrs_interval TO nrt_interval.


    TRY.
        CALL METHOD cl_numberrange_intervals=>create  " Interval Object 생성
          EXPORTING
            interval  = nrt_interval
            object    = 'ZNR_PIR_JY'    " Object 이름
            subobject = ''
          IMPORTING
            error     = DATA(error)
            error_inf = DATA(error_inf)
            error_iv  = DATA(error_iv).

        " 성공 시 메시지 출력
        out->write( |Interval '01' created successfully for { nr_attribute-object }.| ).

      CATCH cx_nr_object_not_found INTO DATA(lx_no_obj_found).
        " 실패 시 메시지 출력
        out->write( 'Object not found.' ).
      CATCH cx_number_ranges INTO DATA(cx_number_ranges).
        " 실패 시 메시지 출력
        out->write( |Error creating Interval: { cx_number_ranges->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.

