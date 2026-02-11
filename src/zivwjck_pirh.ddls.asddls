@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[이원준] PIRH 데이터 인터페이스 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZIVWJCK_PIRH as select from ztckpirh
composition [1..*] of ZIVWJCK_PIRI as _PIRI
association [1..1] to ZDVCK_PLT_VH as _PlantText 
    on $projection.Werks = _PlantText.werks
{
    key ztckpirh.pirnr as Pirnr,
    @ObjectModel.text.element: ['PlantName']
    ztckpirh.werks as Werks,
    _PlantText.wernm as PlantName, //플랜트 텍스트 필드 실체화
    ztckpirh.pirdt as Pirdt,
    ztckpirh.pirvr as Pirvr,
    ztckpirh.aimod as Aimod,
    ztckpirh.aidat as Aidat,
    ztckpirh.erdat as Erdat,
    ztckpirh.ernam as Ernam,
    ztckpirh.pirart as Pirart,
    ztckpirh.pirdel as Pirdel,
    ztckpirh.local_last_changed_at as LocalLastChangedAt,
    ztckpirh.last_changed_at as LastChangedAt,
    
    _PIRI,
    _PlantText
}
