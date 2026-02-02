@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PIR 라인아이템 Projection View 생성'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZPVCK_PIRI
  as projection on ZDVCK_PIRI
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

      _Header : redirected to parent ZPVCK_PIRH // 부모자식 간 통로 재설정
}
