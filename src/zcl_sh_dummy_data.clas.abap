CLASS zcl_sh_dummy_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sh_dummy_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA: lt_data TYPE TABLE OF ztcksh.

    " out->write( )
    delete from ztcksh.

    lt_data = VALUE #(
     (
        sshnr = 'S000000001' " 판매이력 문서번호
        shdat = '20251220'   " 판매일자
        matnr = 'MOD-01-A'   " 자재번호
        menge = '500'        " 수량
        meins = 'EA'         " 단위
        werks = '1000'       " 플랜트
        lgort = '100'        " 창고
        kunnr = 'K000000001' " 고객코드
      )
      (
        sshnr = 'S000000002' " 판매이력 문서번호
        shdat = '20221220'   " 판매일자
        matnr = 'MOD-02-A'   " 자재번호
        menge = '200'        " 수량
        meins = 'EA'         " 단위
        werks = '1000'       " 플랜트
        lgort = '100'        " 창고
        kunnr = 'K000000001' " 고객코드
      )
           (
        sshnr = 'S000000003' " 판매이력 문서번호
        shdat = '20231220'   " 판매일자
        matnr = 'MOD-03-A'   " 자재번호
        menge = '100'        " 수량
        meins = 'EA'         " 단위
        werks = '1000'       " 플랜트
        lgort = '100'        " 창고
        kunnr = 'K000000001' " 고객코드
      )
           (
        sshnr = 'S000000004' " 판매이력 문서번호
        shdat = '20241220'   " 판매일자
        matnr = 'MOD-01-A'   " 자재번호
        menge = '50'        " 수량
        meins = 'EA'         " 단위
        werks = '1000'       " 플랜트
        lgort = '100'        " 창고
        kunnr = 'K000000001' " 고객코드
      )
    ).

    INSERT ztcksh FROM TABLE @lt_data.

    " 4. 결과 출력
    IF sy-subrc = 0.
      out->write( |Success! { lines( lt_data ) } rows inserted.| ).
    ELSE.
      out->write( 'Error inserting data.' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
