@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PIR 헤더 Projection View 생성'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZPVCK_PIRH
  provider contract transactional_query // 트랜잭션 작업(CRUD)을 위해 설계되었음을 알림
  as projection on ZDVCK_PIRH
{
  key pirnr,
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'wernm' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZDVCK_PLT_VH', element: 'werks' } }]
      werks,
      wernm,
      pirdt,
      pirvr,
      aimod,
      aidat,
      erdat,
      ernam,
      pirart,
      pirdel,
      _Items : redirected to composition child ZPVCK_PIRI // 부모자식 간 통로 재설정

}
