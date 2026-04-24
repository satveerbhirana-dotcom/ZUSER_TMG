@EndUserText.label: 'Table For User Id Password Tmg'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZI_TableForUserIdPassw
  as select from zuser_id
  association to parent ZI_TableForUserIdPassw_S as _TableForUserIdPaAll on $projection.SingletonID = _TableForUserIdPaAll.SingletonID
{
  key userid as Userid,
  username as Username,
  password as Password,
  email    as Email ,
  contact  as Contact,
  @Consumption.hidden: true
  1 as SingletonID,
  _TableForUserIdPaAll
  
}
