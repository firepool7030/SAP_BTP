CLASS zcl_plt_dummy_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_plt_dummy_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_data TYPE TABLE OF ztckplt.

    lt_data = VALUE #(
        (
         werks = 1000
         wernm = '물류 플랜트'
         waddr = 'North Korea, Pyongyang'
        )
        (
         werks = 2000
         wernm = '생산 플랜트'
         waddr = 'South Korea, Sadang'
        )
    ).

    INSERT ztckplt FROM TABLE @lt_data.

    if sy-subrc = 0.
        out->write( |Succese! { lines( lt_data ) } rows inserted.| ).
    ELSE.
        out->write( |Error| ).
    endif.


  ENDMETHOD.


ENDCLASS.
