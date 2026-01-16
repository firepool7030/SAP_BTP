@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[이원준] PIRI 데이터 인터페이스 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZIVWJCK_PIRI as select from ztckpiri
association to parent ZIVWJCK_PIRH as _PIRH
    on $projection.pirnr = _PIRH.pirnr
{
    key pirnr,
    key iteno,
    matnr,
    @Semantics.quantity.unitOfMeasure: 'Meins'
    plqty,
    @Semantics.quantity.unitOfMeasure: 'Meins'
    aiqty,
    @Semantics.quantity.unitOfMeasure: 'Meins'
    urqty,
    @Semantics.quantity.unitOfMeasure: 'Meins'
    plnmg,
    meins,
    cnflv,
    
    _PIRH
}
