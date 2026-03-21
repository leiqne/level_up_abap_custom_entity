@EndUserText.label: 'Custom entity PO'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_EGUI_PO_QUERY_GEMINI'
define custom entity zegui_ce_purchaseorder
{
  key Poid : zegui_id;
  Orderdate : zegui_order_date;
  Deliverydate : zegui_deliverydate;
  status  :zegui_status;
  currencycode : zegui_currency;  
  last_changed_at : timestamp;
  @Semantics.amount.currencyCode: 'currencycode'
  totalprice : zegui_total_amount;
  
  
  @Consumption.valueHelpDefinition: [{ entity: { name: 'zegui_c_buyer' , element: 'BuyerId' } }]
  buyerid : sysuuid_x16;
  
  Sumarry : abap.string;
}
