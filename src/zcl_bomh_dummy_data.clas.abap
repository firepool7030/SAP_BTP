CLASS zcl_bomh_dummy_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_bomh_dummy_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA lt_data TYPE TABLE OF ztckbomh.

    lt_data = VALUE #(
     (
       bohnr = 'BOM-P00001'  " BOM 헤더번호
       boart = '1'           " BOM 유형 (1:팩 분해, 2:모듈분해)
       matnr = 'PACK-01'     " 분해할 자재번호
       werks = '2000'        " 플랜트 (1000:물류, 2000:생산)
       lgort = '100'         " 창고 (100:팩, 200:모듈/대기)
      )
     (
       bohnr = 'BOM-P00002'  " BOM 헤더번호
       boart = '1'           " BOM 유형 (1:팩 분해, 2:모듈분해)
       matnr = 'PACK-02'     " 분해할 자재번호
       werks = '2000'        " 플랜트 (1000:물류, 2000:생산)
       lgort = '100'         " 창고 (100:팩, 200:모듈/대기)
      )
     (
       bohnr = 'BOM-M00001'  " BOM 헤더번호
       boart = '2'           " BOM 유형 (1:팩 분해, 2:모듈분해)
       matnr = 'MOD-01-F'     " 분해할 자재번호
       werks = '2000'        " 플랜트 (1000:물류, 2000:생산)
       lgort = '200'         " 창고 (100:팩, 200:모듈/대기)
      )
     (
       bohnr = 'BOM-M00002'  " BOM 헤더번호
       boart = '2'           " BOM 유형 (1:팩 분해, 2:모듈분해)
       matnr = 'MOD-02-F'     " 분해할 자재번호
       werks = '2000'        " 플랜트 (1000:물류, 2000:생산)
       lgort = '200'         " 창고 (100:팩, 200:모듈/대기)
      )
    ).

    INSERT ztckbomh FROM TABLE @lt_data.

    IF sy-subrc = 0.
      out->write( |Success! { lines( lt_data ) } rows inserted.| ).
    ELSE.
      out->write( 'Error inserting data.' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
