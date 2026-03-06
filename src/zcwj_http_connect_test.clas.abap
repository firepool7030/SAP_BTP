CLASS zcwj_http_connect_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    interfaces if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcwj_http_connect_test IMPLEMENTATION.

  method if_oo_adt_classrun~main.

    " ngrok api url 데이터로 정의 (항상 가변적이니 계속 바꿔주자)
    DATA: ngrok_url TYPE string VALUE 'https://2177-2001-e60-8805-4b10-50a1-f7dd-6ebd-32cb.ngrok-free.app'.

    " HTTP 메세지 통신용 변수
    DATA: lo_client         type ref to if_web_http_client,
          lo_request        type ref to if_web_http_request,
          lo_response       type ref to if_web_http_response,
          lo_dest           type ref to if_http_destination,

          lx_web_error      type ref to cx_web_http_client_error,   "파이썬 서버에 도달 조차 못할때 나오는 에러 잡는 변수
          lx_dest_error     type ref to cx_http_dest_provider_error."

    " 통신 시도
    try.

      " SELECT로 헤더/아이템 데이터 변수에 넣기.------------------------------------------
      out->write( '<<HTTP 통신 및 데이터 전송 테스트 시작>>' ).

      TYPES: BEGIN OF ts_slim_item,
               shdat TYPE ztcksh-shdat, " 판매일자
               matnr TYPE ztcksh-matnr, " 자재번호
               menge TYPE ztcksh-menge, " 수량
             END OF ts_slim_item.

      TYPES: BEGIN OF ts_root,
               history_items TYPE STANDARD TABLE OF ts_slim_item WITH DEFAULT KEY,
             END OF ts_root.

      DATA: ls_request_data TYPE ts_root.

      " ZTCKSH 테이블 전체 조회 (SELECT)
      SELECT shdat, matnr, menge
        FROM ztcksh
        INTO CORRESPONDING FIELDS OF TABLE @ls_request_data-history_items.

      IF ls_request_data-history_items IS INITIAL.
        out->write( 'DB에 데이터가 없습니다.' ).
        RETURN.
      ENDIF.

      " JSON 형식으로 데이터 수정
      DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_request_data ).

      out->write( |생성된 JSON: { lv_json }| ).


      " 1. 문자열 URL을 Destination 객체로 변환----------------------------------------
      lo_dest = cl_http_destination_provider=>create_by_url( ngrok_url ).

      " 2. 변환된 객체를 사용해서 클라이언트 객체 생성
      lo_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

      " 3. 요청 객체값 설정
      lo_request = lo_client->get_http_request( ).
      lo_request->set_uri_path( '/predict' ). " 사용할 API의 엔드포인트 설정
      lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ). " 헤더에 데이터 내용물 타입이 JSON이라고 선언

      " 4. 객체에 데이터 넣고 서버에 전송
      lo_request->set_text( lv_json ). " 보내줄 더미데이터 입력 -> 나중에 수정 필요!
      lo_response = lo_client->execute( i_method = if_web_http_client=>post ). " 위에 더미 데이터를 넣고 python에 post하기

      " 6. 결과 수신 및 출력 (이 부분이 가장 중요!)
        DATA(lv_status) = lo_response->get_status( ).
        DATA(lv_response_body) = lo_response->get_text( ).

        out->write( '--------------------------------' ).
        out->write( |응답 상태 코드: { lv_status-code }| ).
        out->write( |응답 데이터: { lv_response_body }| ).
        out->write( '--------------------------------' ).

        IF lv_status-code = 200.
          out->write( '>>> 성공적으로 예측값을 받아왔습니다! 🎉' ).
        ELSE.
          out->write( '>>> 전송은 됐지만 오류가 있습니다. (4xx/500 에러)' ).
        ENDIF.

      " 예외처리 1: 통신 실패 (에러 내용을 봐야 고칠 수 있습니다)
      CATCH cx_web_http_client_error INTO lx_web_error.
        DATA(lv_err_msg) = lx_web_error->get_text( ).
        out->write( |!!! 통신 에러 발생 !!!: { lv_err_msg }| ).

      " 예외처리 2: URL 변환 에러
      CATCH cx_http_dest_provider_error INTO lx_dest_error.
        DATA(lv_dest_msg) = lx_dest_error->get_text( ).
        out->write( |!!! URL 설정 에러 !!!: { lv_dest_msg }| ).

    ENDTRY.

  endmethod.

ENDCLASS.
