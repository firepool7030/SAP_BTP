@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Plant Value Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZDVCK_PLT_VH
  as select from ztckplt
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'wernm' ]
  key werks,
      @Search.defaultSearchElement: true
      wernm,
      @Search.defaultSearchElement: true
      waddr
}
