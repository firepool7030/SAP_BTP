CLASS zcl_pir_dummy_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_pir_dummy_data IMPLEMENTATION.

    METHOD if_oo_adt_classrun~main.

        DATA: lt_data TYPE TABLE OF ztckpirh.

        DELETE FROM ztckpirh.

        lt_data = VALUE #(
          (
            pirnr  = '1000000001'      " PIR 번호 (키값)
            werks  = '1000'            " 플랜트
            pirdt  = '20240115'        " 날짜 (YYYYMMDD)
            pirvr  = '00'              " 버전
            aimod  = 'A'               " 모드
            aidat  = '20240115'        " 생성일?
            erdat  = sy-datum          " 시스템 날짜
            ernam  = sy-uname          " 생성자 ID
            pirart = 'NB'              " 유형
            pirdel = ''                " 삭제 플래그
          )
          (
            pirnr  = '1000000002'
            werks  = '2000'
            pirdt  = '20240220'
            pirvr  = '01'
            aimod  = 'B'
            aidat  = '20240220'
            erdat  = sy-datum
            ernam  = sy-uname
            pirart = 'UB'
            pirdel = 'X'
          )
        ).

        " 3. 데이터 삽입 (INSERT)
        INSERT ztckpirh FROM TABLE @lt_data.

        " 4. 결과 출력
        IF sy-subrc = 0.
          out->write( |Success! { lines( lt_data ) } rows inserted.| ).
        ELSE.
          out->write( 'Error inserting data.' ).
        ENDIF.

    ENDMETHOD.

ENDCLASS.
