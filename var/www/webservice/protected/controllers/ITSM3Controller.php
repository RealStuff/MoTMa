<?php

/**
 *
 * @author wengera
 *
 */
class ITSM3Controller extends Controller {
  
  public function actions() {
  
    return array(
      'SWI_PartnerIncidentResponse_03' => array(
        'class' => 'CWebServiceAction',
        'classMap'=>array(
          'Ticketitem',
        //     'incidentnumber',
        //     'Contact',
        //     'Worklog'
        ),
      )
    );
  }
  
  /**
   * @param string incidentnumber
   * @param string partnerincidentnumber
   * @param string lookupdate
   * @return Ticketitem[]
   * @soap
   */
  public function get($incidentnumber, $partnerincidentnumber, $lookupdate) {
    
    $criteria=new CDbCriteria;
    if (isset($incidentnumber))
      $criteria->compare('incidentnumber', $incidentnumber);
    if (isset($partnerincidentnumber))
      $criteria->compare('partnerincidentnumber', $partnerincidentnumber);
    
    return Ticketitem::model()->findAll($criteria);
  }
}
?>
