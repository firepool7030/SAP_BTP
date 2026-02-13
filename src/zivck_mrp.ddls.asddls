@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MRP 인터페이스 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZIVCK_MRP
  as select from ztckmrp
  association [1..1] to ZIVWJCK_PIRH as _PIRH on $projection.Pirnr = _PIRH.Pirnr
  association [1..*] to ZIVCK_BOMH   as _BOMH on $projection.Matnr = _BOMH.Matnr
{
  key ztckmrp.mrpnr as Mrpnr,
      ztckmrp.pirnr as Pirnr,
      ztckmrp.mrpdt as Mrpdt,
      ztckmrp.werks as Werks,
      ztckmrp.matnr as Matnr,
      @Semantics.quantity.unitOfMeasure: 'Meins'
      ztckmrp.menge as Menge,
      ztckmrp.meins as Meins,
      ztckmrp.doart as Doart,
      ztckmrp.docnr as Docnr,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at,
      _PIRH,
      _BOMH
}
