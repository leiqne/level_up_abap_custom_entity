@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface cds gemini resp'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zegui_i_gem_resp as select from zegui_gem_resp
{
    key poid as Poid,
    status as Status,
    summary as Summary
}
