@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MRP 프로젝션 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZPVCK_MRP
  provider contract transactional_query
  as projection on ZIVCK_MRP
{
  key Mrpnr,
      Pirnr,
      Mrpdt,
      Werks,
      Matnr,
      @Semantics.quantity.unitOfMeasure: 'Meins'
      Menge,
      Meins,
      Doart,
      Docnr,
      local_last_changed_at,
      last_changed_at,
      /* Associations */
      _BOMH,
      _PIRH
}
