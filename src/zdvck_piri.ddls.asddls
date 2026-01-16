@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PIR 라인아이템 Interface View 생성'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZDVCK_PIRI
  as select from ztckpiri

  association to parent ZDVCK_PIRH as _Header on $projection.pirnr = _Header.pirnr
{

  key pirnr,
  key iteno,
      matnr,
      @Semantics.quantity.unitOfMeasure: 'meins'
      plqty,
      @Semantics.quantity.unitOfMeasure: 'meins'
      aiqty,
      @Semantics.quantity.unitOfMeasure: 'meins'
      urqty,
      @Semantics.quantity.unitOfMeasure: 'meins'
      plnmg,
      meins,
      cnflv,

      _Header

}

