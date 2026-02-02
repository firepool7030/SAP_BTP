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
    DATA: ngrok_url TYPE string VALUE 'https://af5370cd0ff7.ngrok-free.app'.

    " HTTP 메세지 통신용 변수
    DATA: lo_client         type ref to if_web_http_client,
          lo_request        type ref to if_web_http_request,
          lo_response       type ref to if_web_http_response,
          lo_dest           type ref to if_http_destination,

          lx_web_error      type ref to cx_web_http_client_error,   "파이썬 서버에 도달 조차 못할때 나오는 에러 잡는 변수
          lx_dest_error     type ref to cx_http_dest_provider_error."

    DATA(lv_test_pirnr) = '1000000001'. " 테스트 pirnr 번호

    TYPES: BEGIN OF ty_json_root,       " JSON 구조체 정의
             pir_id TYPE string,
             items  TYPE STANDARD TABLE OF ztckpiri WITH DEFAULT KEY,
           END OF ty_json_root.
    DATA: ls_root_data TYPE ty_json_root.


    " 통신 시도
    try.

      " SELECT로 헤더/아이템 데이터 변수에 넣기.------------------------------------------
      out->write( '<<HTTP 통신 및 데이터 전송 테스트 시작>>' ).
      out->write( |조회 대상 PIR 번호: { lv_test_pirnr }| ).

      " 아이템 테이블(ZTCKPIRI)에서 직접 조회
      SELECT *
        FROM ztckpiri
        WHERE pirnr = @lv_test_pirnr
        INTO TABLE @DATA(lt_items).

      IF sy-subrc <> 0.
        out->write( '!!! DB에 해당 번호의 데이터가 없습니다. 번호를 확인하세요 !!!' ).
        RETURN.
      ENDIF.

      out->write( |조회된 아이템 건수: { lines( lt_items ) } 건| ).

      " 데이터를 활요애서 JSON 형식으로 변환 /ui2/cl_json 사용-----------------------------
      ls_root_data-pir_id = lv_test_pirnr.
      ls_root_data-items = lt_items.

      " JSON으로 변환
      DATA(lv_json_body) = /ui2/cl_json=>serialize(
                               data        = ls_root_data
                               compress    = abap_true
                               pretty_name = /ui2/cl_json=>pretty_mode-low_case
                             ).

      out->write( |생성된 JSON: { lv_json_body }| ).


      " 1. 문자열 URL을 Destination 객체로 변환----------------------------------------
      lo_dest = cl_http_destination_provider=>create_by_url( ngrok_url ).

      " 2. 변환된 객체를 사용해서 클라이언트 객체 생성
      lo_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

      " 3. 요청 객체값 설정
      lo_request = lo_client->get_http_request( ).
      lo_request->set_uri_path( '/predict' ). " 사용할 API의 엔드포인트 설정
      lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ). " 헤더에 데이터 내용물 타입이 JSON이라고 선언

      " 4. 객체에 데이터 넣고 서버에 전송
      lo_request->set_text( lv_json_body ). " 보내줄 더미데이터 입력 -> 나중에 수정 필요!
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
          out->write( '>>> 전송은 됐지만 오류가 있습니다. (400/500 에러)' ).
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
