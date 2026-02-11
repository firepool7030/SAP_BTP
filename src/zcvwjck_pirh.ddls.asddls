@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[이원준] PIRI 데이터 프로젝션 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCVWJCK_PIRH 
    provider contract transactional_query
    as projection on ZIVWJCK_PIRH
{
    key Pirnr,          // PIR 문서번호
    @UI.textArrangement: #TEXT_LAST
    @ObjectModel.text.element: [ 'PlantName' ]
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZDVCK_PLT_VH', element: 'werks' } }]
    Werks,              // 플랜트     
    PlantName,          // 플랜트명
    Pirdt,              // PIR 계획일자
    Pirvr,              // PIR 계획버전
    Aimod,              // AI 모델 ID
    Aidat,              // AI 예측일  
    Erdat,              // 문서 생성일  
    Ernam,              // 문서 생성자  
    Pirart,             // PIR 문서상태
    Pirdel,             // 삭제 플래그  
    LocalLastChangedAt, // 헤더 변경 일자
    LastChangedAt,      // 아이템 변경 일자
    
    /* Associations */
    _PIRI: redirected to composition child ZCVWJCK_PIRI
}
