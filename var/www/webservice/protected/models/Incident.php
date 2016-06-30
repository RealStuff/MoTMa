<?php

/**
 * This is the model class for table "incident".
 *
 * The followings are the available columns in table 'incident':
 * @property integer $idincident
 * @property string $priority
 * @property string $impact
 * @property string $urgency
 * @property string $description
 * @property string $detail
 * @property string $submitdate
 * @property string $targetresolutiondate
 * @property string $customer
 * @property string $productname
 *
 * The followings are the available model relations:
 * @property Ticketitem[] $ticketitems
 */
class Incident extends CActiveRecord
{
    /**
	 * @var string
	 * @soap
	 */
	public $priority;
	
	/**
	 * @var string
	 * @soap
	 */
	public $impact;
	
	/**
	 * @var string
	 * @soap
	 */
	public $urgency;
	
	/**
	 * @var string
	 * @soap
	 */
	public $description;
	
	/**
	 * @var string
	 * @soap
	 */
	public $detail;
	
	/**
	 * @var string
	 * @soap
	 */
	public $submitdate;
	
	/**
	 * @var string
	 * @soap
	 */
	public $targetresolutiondate;
	
	/**
	 * @var string
	 * @soap
	 */
	public $customer;
	
	/**
	 * @var string
	 * @soap
	 */
	public $productname;
	
    /**
     * @return string the associated database table name
     */
    public function tableName()
    {
        return 'incident';
    }

    /**
     * @return array validation rules for model attributes.
     */
    public function rules()
    {
        // NOTE: you should only define rules for those attributes that
        // will receive user inputs.
        return array(
            array('priority, impact, urgency, description, detail, submitdate, targetresolutiondate, customer, productname', 'safe'),
            // The following rule is used by search().
            // @todo Please remove those attributes that should not be searched.
            array('idincident, priority, impact, urgency, description, detail, submitdate, targetresolutiondate, customer, productname', 'safe', 'on'=>'search'),
        );
    }

    /**
     * @return array relational rules.
     */
    public function relations()
    {
        // NOTE: you may need to adjust the relation name and the related
        // class name for the relations automatically generated below.
        return array(
            'ticketitems' => array(self::HAS_MANY, 'Ticketitem', 'idincident'),
        );
    }

    /**
     * @return array customized attribute labels (name=>label)
     */
    public function attributeLabels()
    {
        return array(
            'idincident' => 'Idincident',
            'priority' => 'Priority',
            'impact' => 'Impact',
            'urgency' => 'Urgency',
            'description' => 'Description',
            'detail' => 'Detail',
            'submitdate' => 'Submitdate',
            'targetresolutiondate' => 'Targetresolutiondate',
            'customer' => 'Customer',
            'productname' => 'Productname',
        );
    }

    /**
     * Retrieves a list of models based on the current search/filter conditions.
     *
     * Typical usecase:
     * - Initialize the model fields with values from filter form.
     * - Execute this method to get CActiveDataProvider instance which will filter
     * models according to data in model fields.
     * - Pass data provider to CGridView, CListView or any similar widget.
     *
     * @return CActiveDataProvider the data provider that can return the models
     * based on the search/filter conditions.
     */
    public function search()
    {
        // @todo Please modify the following code to remove attributes that should not be searched.

        $criteria=new CDbCriteria;

        $criteria->compare('idincident',$this->idincident);
        $criteria->compare('priority',$this->priority,true);
        $criteria->compare('impact',$this->impact,true);
        $criteria->compare('urgency',$this->urgency,true);
        $criteria->compare('description',$this->description,true);
        $criteria->compare('detail',$this->detail,true);
        $criteria->compare('submitdate',$this->submitdate,true);
        $criteria->compare('targetresolutiondate',$this->targetresolutiondate,true);
        $criteria->compare('customer',$this->customer,true);
        $criteria->compare('productname',$this->productname,true);

        return new CActiveDataProvider($this, array(
            'criteria'=>$criteria,
        ));
    }

    /**
     * Returns the static model of the specified AR class.
     * Please note that you should have this exact method in all your CActiveRecord descendants!
     * @param string $className active record class name.
     * @return Incident the static model class
     */
    public static function model($className=__CLASS__)
    {
        return parent::model($className);
    }
}