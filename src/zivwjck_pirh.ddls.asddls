@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[이원준] PIRH 데이터 인터페이스 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZIVWJCK_PIRH as select from ztckpirh
composition [1..*] of ZIVWJCK_PIRI as _PIRI
{
    key pirnr,
    werks,
    pirdt,
    pirvr,
    aimod,
    aidat,
    erdat,
    ernam,
    pirart,
    pirdel,
    
    _PIRI
}
