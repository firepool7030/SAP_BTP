@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[WJ] PIRI 데이터 프로젝션 뷰 생성'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZCVWJCK_PIRI 
    as projection on ZIVWJCK_PIRI
{
    key pirnr,  // PIR 문서번호
    key iteno,  // PIR 아이템번호
    matnr,      // 자재번호
    @Semantics.quantity.unitOfMeasure: 'Meins'
    plqty,      // 최종계획수량
    @Semantics.quantity.unitOfMeasure: 'Meins'
    aiqty,      // AI 예측수량
    @Semantics.quantity.unitOfMeasure: 'Meins'
    urqty,      // 담당자 입력수량
    @Semantics.quantity.unitOfMeasure: 'Meins'
    plnmg,      // 총 소모수량
    meins,      // 단위
    cnflv,      // 신뢰도
    
    _PIRH : redirected to parent ZCVWJCK_PIRH
}
