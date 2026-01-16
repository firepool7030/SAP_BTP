CLASS zcl_pir_item_dummy_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun. "콘솔 실행을 위한 인터페이스
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_pir_item_dummy_data IMPLEMENTATION.
    METHOD if_oo_adt_classrun~main.

        DATA: lt_data TYPE TABLE OF ztckpiri.

        " 기존 데이터 삭제
        DELETE FROM ztckpiri.

        lt_data = VALUE #(
          " 첫 번째 헤더(1000000001)에 딸린 아이템들
          (
            pirnr = '1000000001'    " 🔑 PIR 헤더번호
            iteno = '0000000001'    " 🔑 PIR 아이템번호
            matnr = 'MOD-01-A'      " 🔐 자재번호
            plqty = '500.000'       " 최종 계획수량
            aiqty = '500.000'       " AI 예측수량
            urqty = '500.000'       " 담당자 입력수량
            plnmg = '490.000'       " 소모 수량
            meins = 'EA'            " 단위
            cnflv = '0.97'          " 예측 신뢰도
          )
          (
            pirnr = '1000000001'    " 🔑 PIR 헤더번호
            iteno = '0000000002'    " 🔑 PIR 아이템번호
            matnr = 'MOD-01-F'      " 🔐 자재번호
            plqty = '750.000'       " 최종 계획수량
            aiqty = '600.000'       " AI 예측수량
            urqty = '750.000'       " 담당자 입력수량
            plnmg = '592.000'       " 소모 수량
            meins = 'EA'            " 단위
            cnflv = '0.82'          " 예측 신뢰도
          )

          " 두 번째 헤더(1000000002)에 딸린 아이템
          (
            pirnr = '1000000002'    " 🔑 PIR 헤더번호
            iteno = '0000000001'    " 🔑 PIR 아이템번호
            matnr = 'MOD-02-A'      " 🔐 자재번호
            plqty = '1250.000'      " 최종 계획수량
            aiqty = '1250.000'      " AI 예측수량
            urqty = '1250.000'      " 담당자 입력수량
            plnmg = '1050.000'      " 소모 수량
            meins = 'EA'            " 단위
            cnflv = '0.99'          " 예측 신뢰도
          )
          (
            pirnr = '1000000002'    " 🔑 PIR 헤더번호
            iteno = '0000000002'    " 🔑 PIR 아이템번호
            matnr = 'MOD-02-F'      " 🔐 자재번호
            plqty = '700.000'       " 최종 계획수량
            aiqty = '650.000'       " AI 예측수량
            urqty = '700.000'       " 담당자 입력수량
            plnmg = '0.000'         " 소모 수량
            meins = 'EA'            " 단위
            cnflv = '0.92'          " 예측 신뢰도
          )
          (
            pirnr = '1000000002'    " 🔑 PIR 헤더번호
            iteno = '0000000003'    " 🔑 PIR 아이템번호
            matnr = 'BP-001'        " 🔐 자재번호
            plqty = '12000.000'     " 최종 계획수량
            aiqty = '15000.000'     " AI 예측수량
            urqty = '12000.000'     " 담당자 입력수량
            plnmg = '9000.000'      " 소모 수량
            meins = 'KG'            " 단위
            cnflv = '0.72'          " 예측 신뢰도
          )
        ).

        " 데이터 삽입
        INSERT ztckpiri FROM TABLE @lt_data.

        " 결과 출력
        IF sy-subrc = 0.
          out->write( |Success! { lines( lt_data ) } items inserted into ZTCKPIRI.| ).
        ELSE.
          out->write( 'Error inserting data. (Check Column Names or Types)' ).
        ENDIF.

    ENDMETHOD.
ENDCLASS.
