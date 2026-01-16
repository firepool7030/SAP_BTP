@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PIR 헤더 Interface View 생성'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity ZDVCK_PIRH
  as select from ztckpirh

  composition [0..*] of ZDVCK_PIRI as _Items
  // association [1..1] to ZDVCK_PLT_VH as _Plant on $projection.werks = _Plant.werks
{
  key pirnr,

      //  @ObjectModel.foreignKey.association: '_Plant'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZDVCK_PLT_VH', element: 'werks' } }]

      werks,
      pirdt,
      pirvr,
      aimod,
      aidat,
      erdat,
      ernam,
      pirart,
      pirdel,

      _Items
      //     _Plant
}
