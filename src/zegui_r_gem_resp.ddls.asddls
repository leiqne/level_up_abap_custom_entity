@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transactional CDS gemini resp'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zegui_r_gem_resp as select from zegui_i_gem_resp
{
    key Poid,
    Status,
    Summary
}
