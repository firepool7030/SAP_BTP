@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOMI 인터페이스 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZIVCK_BOMI
  as select from ztckbomi
  association to parent ZIVCK_BOMH as _BOMH on $projection.Bohnr = _BOMH.Bohnr
{
    key ztckbomi.bohnr as Bohnr,
    key ztckbomi.boinr as Boinr,
    ztckbomi.matnr as Matnr,
    @Semantics.quantity.unitOfMeasure: 'Meins'
    ztckbomi.menge as Menge,
    ztckbomi.meins as Meins,
    _BOMH
}
