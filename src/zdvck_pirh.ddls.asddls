@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PIR 헤더 Interface View 생성'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity ZDVCK_PIRH
  as select from ztckpirh

  composition [0..*] of ZDVCK_PIRI   as _Items
  association [1..1] to ZDVCK_PLT_VH as _Plant on $projection.werks = _Plant.werks
{
  key pirnr,

      werks,
      _Plant.wernm,
      pirdt,
      pirvr,
      aimod,
      aidat,
      erdat,
      ernam,
      pirart,
      pirdel,
      case pirdel
        when 'X' then 1 // 삭제됨, 빨간색
        else 3          // 정상,  초록색
      end as light_del,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at,
      _Items,
      _Plant
}
