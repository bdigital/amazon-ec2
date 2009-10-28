require File.dirname(__FILE__) + '/test_helper.rb'

context "elb load balancers " do
  before do
    @rds = AWS::RDS::Base.new( :access_key_id => "not a key", :secret_access_key => "not a secret" )

    @create_db_instance_body = <<-RESPONSE
    <CreateDBInstanceResponse xmlns="http://rds.amazonaws.com/admin/2009-10-16/">
      <CreateDBInstanceResult>
        <DBInstance>
          <Engine>MySQL5.1</Engine>
          <BackupRetentionPeriod>1</BackupRetentionPeriod>
          <DBInstanceStatus>creating</DBInstanceStatus>
          <DBInstanceIdentifier>mydbinstance</DBInstanceIdentifier>
          <PreferredBackupWindow>03:00-05:00</PreferredBackupWindow>
          <DBSecurityGroups>
            <DBSecurityGroup>
              <Status>active</Status>
              <DBSecurityGroupName>default</DBSecurityGroupName>
            </DBSecurityGroup>
          </DBSecurityGroups>
          <PreferredMaintenanceWindow>sun:05:00-sun:09:00</PreferredMaintenanceWindow>
          <AllocatedStorage>10</AllocatedStorage>
          <DBInstanceClass>db.m1.large</DBInstanceClass>
          <MasterUsername>master</MasterUsername>
        </DBInstance>
      </CreateDBInstanceResult>
      <ResponseMetadata>
        <RequestId>e6fb58c5-bf34-11de-b88d-993294bf1c81</RequestId>
      </ResponseMetadata>
    </CreateDBInstanceResponse>
    RESPONSE
    @create_db_security_group = <<-RESPONSE
    <CreateDBSecurityGroupResponse xmlns="http://rds.amazonaws.com/admin/2009-10-16/">
      <CreateDBSecurityGroupResult>
        <DBSecurityGroup>
          <EC2SecurityGroups/>
          <DBSecurityGroupDescription>My new DBSecurityGroup</DBSecurityGroupDescription>
          <IPRanges/>
          <OwnerId>621567473609</OwnerId>
          <DBSecurityGroupName>mydbsecuritygroup4</DBSecurityGroupName>
        </DBSecurityGroup>
      </CreateDBSecurityGroupResult>
      <ResponseMetadata>
        <RequestId>c9cf9ff2-bf36-11de-b88d-993294bf1c81</RequestId>
      </ResponseMetadata>
    </CreateDBSecurityGroupResponse>
    RESPONSE
  end
  
  specify "should be able to be create a db_isntance" do
    @rds.stubs(:make_request).with('CreateDBInstance', {'Engine' => 'MySQL5.1', 
        'MasterUsername' => 'master', 
        'DBInstanceClass' => 'db.m1.large', 
        'DBInstanceIdentifier' => 'testdb', 
        'AllocatedStorage' => '10', 
        'MasterUserPassword' => 'SecretPassword01'}).
      returns stub(:body => @create_db_instance_body, :is_a? => true)
    response = @rds.create_db_instance(
      :db_instance_class => "db.m1.large", 
      :db_instance_identifier=>"testdb",
      :allocated_storage => 10,
      :engine => "MySQL5.1",
      :master_user_password => "SecretPassword01",
      :master_username => "master"
      )
    response.should.be.an.instance_of Hash

    assert_equal response.CreateDBInstanceResult.DBInstance.AllocatedStorage, "10"
  end

  specify "should be able to create_db_security_group" do
    @rds.stubs(:make_request).with('CreateDBSecurityGroup', {
                      'DBSecurityGroupName' => 'mydbsecuritygroup', 
                      'DBSecurityGroupDescription' => 'My new DBSecurityGroup'}).
      returns stub(:body => @create_db_security_group, :is_a? => true)
    response = @rds.create_db_security_group(
        :db_security_group_name => "mydbsecuritygroup",
        :db_security_group_description => "My new DBSecurityGroup"
      )
    response.should.be.an.instance_of Hash

    assert_equal response.CreateDBSecurityGroupResult.DBSecurityGroup.DBSecurityGroupName, "mydbsecuritygroup4"
  end
  
end