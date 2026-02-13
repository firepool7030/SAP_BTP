CLASS zcl_bomi_dummy_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_bomi_dummy_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA lt_data TYPE TABLE OF ztckbomi.

    lt_data = VALUE #(
     (
       BOHNR = 'BOM-P00001' " BOM 헤더번호
       BOINR = '1'          " BOM 라인번호
       MATNR = 'MOD-01-A'   " 생성될 자재번호
       MENGE = '6'          " 수량
       MEINS = 'EA'         " 단위
     )
     (
       BOHNR = 'BOM-P00001' " BOM 헤더번호
       BOINR = '2'          " BOM 라인번호
       MATNR = 'MOD-01-F'   " 생성될 자재번호
       MENGE = '2'          " 수량
       MEINS = 'EA'         " 단위
     )

     (
       BOHNR = 'BOM-P00002' " BOM 헤더번호
       BOINR = '1'          " BOM 라인번호
       MATNR = 'MOD-02-A'   " 생성될 자재번호
       MENGE = '10'         " 수량
       MEINS = 'EA'         " 단위
     )
     (
       BOHNR = 'BOM-P00002' " BOM 헤더번호
       BOINR = '2'          " BOM 라인번호
       MATNR = 'MOD-02-F'   " 생성될 자재번호
       MENGE = '2'          " 수량
       MEINS = 'EA'         " 단위
     )

     (
       BOHNR = 'BOM-M00001' " BOM 헤더번호
       BOINR = '1'          " BOM 라인번호
       MATNR = 'BP-001'     " 생성될 자재번호
       MENGE = '18'         " 수량
       MEINS = 'KG'         " 단위
     )
     (
       BOHNR = 'BOM-M00002' " BOM 헤더번호
       BOINR = '1'          " BOM 라인번호
       MATNR = 'BP-001'     " 생성될 자재번호
       MENGE = '22'         " 수량
       MEINS = 'KG'         " 단위
     )
    ).

    INSERT ztckbomi FROM TABLE @lt_data.

    IF sy-subrc = 0.
      out->write( |Success! { lines( lt_data ) } rows inserted.| ).
    ELSE.
      out->write( 'Error inserting data.' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
