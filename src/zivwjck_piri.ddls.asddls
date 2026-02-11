@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[이원준] PIRI 데이터 인터페이스 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZIVWJCK_PIRI as select from ztckpiri
association to parent ZIVWJCK_PIRH as _PIRH
    on $projection.Pirnr = _PIRH.Pirnr
{
    key ztckpiri.pirnr as Pirnr,
    key ztckpiri.iteno as Iteno,
    ztckpiri.matnr as Matnr,
    @Semantics.quantity.unitOfMeasure: 'Meins'
    ztckpiri.plqty as Plqty,
    @Semantics.quantity.unitOfMeasure: 'Meins'
    ztckpiri.aiqty as Aiqty,
    @Semantics.quantity.unitOfMeasure: 'Meins'
    ztckpiri.urqty as Urqty,
    @Semantics.quantity.unitOfMeasure: 'Meins'
    ztckpiri.plnmg as Plnmg,
    ztckpiri.meins as Meins,
    ztckpiri.cnflv as Cnflv,
    ztckpiri.local_last_changed_at as LocalLastChangedAt,
    
    _PIRH
}
