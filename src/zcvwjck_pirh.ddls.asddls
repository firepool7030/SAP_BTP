@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[이원준] PIRI 데이터 프로젝션 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCVWJCK_PIRH 
    provider contract transactional_query
    as projection on ZIVWJCK_PIRH
{
    key pirnr,  // PIR 문서번호 
    werks,      // 플랜트 
    pirdt,      // PIR 계획일자
    pirvr,      // PIR 계획버전
    aimod,      // AI 모델 ID
    aidat,      // AI 예측일
    erdat,      // 문서 생성일
    ernam,      // 문서 생성자
    pirart,     // PIR 문서상태
    pirdel,     // 삭제 플래그
    
    _PIRI : redirected to composition child ZCVWJCK_PIRI
}
