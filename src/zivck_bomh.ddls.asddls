@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOMH 인터페이스 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZIVCK_BOMH
  as select from ztckbomh
  composition [1..*] of ZIVCK_BOMI as _BOMI
{
  key ztckbomh.bohnr as Bohnr,
      ztckbomh.boart as Boart,
      ztckbomh.matnr as Matnr,
      ztckbomh.werks as Werks,
      ztckbomh.lgort as Lgort,
      _BOMI
}
