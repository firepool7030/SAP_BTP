@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Plant Value Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity ZDVCK_PLT_VH
  as select from ztckplt
{
      @Search.defaultSearchElement: true
  key werks,
      @Search.defaultSearchElement: true
      wernm,
      @Search.defaultSearchElement: true
      waddr
}
