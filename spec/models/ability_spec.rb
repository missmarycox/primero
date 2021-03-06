require 'spec_helper'

describe Ability do

  CRUD = [:index, :create, :view, :edit, :update, :destroy]

  before do
    @user1 = create :user
    @user2 = create :user
    @permission_case_read = Permission.new(resource: Permission::CASE, actions: [Permission::READ])
    @permission_case_read_write = Permission.new(resource: Permission::CASE, actions: [Permission::READ, Permission::WRITE])
  end

  describe "Records" do

    before :each do
      Child.any_instance.stub(:field_definitions).and_return([])
    end

    it "allows an owned record to be read given a read permission" do
      role = create :role, permissions_list: [@permission_case_read]
      @user1.role_ids = [role.id]
      case1 = create :child, owned_by: @user1.user_name

      ability = Ability.new @user1

      expect(ability).to authorize(:read, Child)
      expect(ability).to authorize(:read, case1)
    end

    it "doesn't allow an owned record to be written to given only a read permission" do
      role = create :role, permissions_list: [@permission_case_read]
      @user1.role_ids = [role.id]
      case1 = create :child, owned_by: @user1.user_name

      ability = Ability.new @user1

      expect(ability).not_to authorize(:write, Child)
      expect(ability).not_to authorize(:write, case1)
    end

    it "allows a non-owned but associated record to be read" do
      role = create :role, permissions_list: [@permission_case_read]
      @user1.role_ids = [role.id]
      case1 = create :child, owned_by: @user2.user_name, assigned_user_names: [@user1.user_name]

      ability = Ability.new @user1

      expect(ability).to authorize(:read, Child)
      expect(ability).to authorize(:read, case1)

    end

    it "allows an owned record to be written to given a write permission" do
      role = create :role, permissions_list: [@permission_case_read_write]
      @user1.role_ids = [role.id]
      case1 = create :child, owned_by: @user1.user_name

      ability = Ability.new @user1

      expect(ability).to authorize(:write, Child)
      expect(ability).to authorize(:write, case1)
    end

    it "allows an owned record to be flagged given a flag permission" do
      permission_flag = Permission.new(resource: Permission::CASE, actions: [Permission::FLAG])
      role = create :role, permissions_list: [permission_flag]
      @user1.role_ids = [role.id]
      case1 = create :child, owned_by: @user1.user_name

      ability = Ability.new @user1

      expect(ability).to authorize(:flag, case1)
    end

    it "allows an owned record to be reassigned" do
      permission_assign = Permission.new(resource: Permission::CASE, actions: [Permission::ASSIGN])
      role = create :role, permissions_list: [permission_assign]
      @user1.role_ids = [role.id]
      case1 = create :child, owned_by: @user1.user_name

      ability = Ability.new @user1

      expect(ability).to authorize(:assign, case1)
    end

    it "doesn't allow a record to be written to even if the record can be flagged and assigned" do
      permission_flag_assign = Permission.new(resource: Permission::CASE, actions: [Permission::FLAG, Permission::ASSIGN])
      role = create :role, permissions_list: [permission_flag_assign]
      @user1.role_ids = [role.id]
      case1 = create :child, owned_by: @user1.user_name

      ability = Ability.new @user1

      expect(ability).not_to authorize(:write, Child)
      expect(ability).not_to authorize(:write, case1)
    end

    it "doesn't allow a record owned by someone else to be managed by a user with no specified scope" do
      role = create :role, permissions_list: [@permission_case_read_write]
      @user1.role_ids = [role.id]
      case1 = create :child, owned_by: @user2.user_name

      ability = Ability.new @user1

      expect(ability).not_to authorize(:read, case1)
      expect(ability).not_to authorize(:write, case1)
    end

    it "doesn't allow a record owned by someone else to be managed by a user with a 'self' scope" do
      role = create :role, permissions_list: [@permission_case_read_write], group_permission: Permission::SELF
      @user1.role_ids = [role.id]
      case1 = create :child, owned_by: @user2.user_name

      ability = Ability.new @user1

      expect(ability).not_to authorize(:read, case1)
      expect(ability).not_to authorize(:write, case1)
    end

    it "allows a record owned by a fellow group member to be managed by a user with 'group' scope" do
      role = create :role, permissions_list: [@permission_case_read_write], group_permission: Permission::GROUP
      @user1.role_ids = [role.id]
      @user1.user_group_ids = ['test_group']
      @user1.save
      @user2.user_group_ids = ['test_group']
      @user2.save
      case1 = create :child, owned_by: @user2.user_name

      ability = Ability.new @user1

      expect(ability).to authorize(:read, case1)
      expect(ability).to authorize(:write, case1)
    end

    it "allows a record owned by someone else to be read by a user with full 'all' scope" do
      role = create :role, permissions_list: [@permission_case_read_write], group_permission: Permission::ALL
      @user1.role_ids = [role.id]
      @user1.user_group_ids = ['test_group']
      @user1.save
      @user2.user_group_ids = ['other_test_group']
      @user2.save
      case1 = create :child, owned_by: @user2.user_name

      ability = Ability.new @user1

      expect(ability).to authorize(:read, case1)
      expect(ability).to authorize(:write, case1)
    end

  end

  describe "Roles" do
    before :each do
      @permission_role_read = Permission.new(resource: Permission::ROLE, actions: [Permission::READ])
      @permission_role_read_write = Permission.new(resource: Permission::ROLE, actions: [Permission::READ, Permission::WRITE])
    end

    it "allows a user with read permissions to read but not edit roles" do
      role = create :role, permissions_list: [@permission_role_read]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      expect(ability).to authorize(:read, Role)
      expect(ability).not_to authorize(:write, Role)
    end

    it "allows a user with read and write permissions to read and edit roles" do
      role = create :role, permissions_list: [@permission_role_read_write]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      expect(ability).to authorize(:read, Role)
      expect(ability).to authorize(:write, Role)
    end

    it "doesn't allow a user with only 'role' permission to manage another user" do
      role = create :role, permissions_list: [@permission_role_read_write]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      expect(ability).not_to authorize(:read, @user2)
      expect(ability).not_to authorize(:write, @user2)
    end

    it "doesn't allow viewing and editing of Groups, and Agencies if only the 'role' permission is set" do
      role = create :role, permissions_list: [@permission_role_read_write]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      [UserGroup, Agency].each do |resource|
        expect(ability).not_to authorize(:read, resource)
        expect(ability).not_to authorize(:write, resource)
      end
    end

    context "when Role Specific permission" do
      before do
        Role.all.each &:destroy
        @permission_case_read = Permission.new(resource: Permission::CASE, actions: [Permission::READ])
        @role_case_read = create :role, permissions_list: [@permission_case_read]
        @permission_tracing_request_read = Permission.new(resource: Permission::CASE, actions: [Permission::READ])
        @role_tracing_request_read = create :role, permissions_list: [@permission_tracing_request_read]
        @permission_incident_read = Permission.new(resource: Permission::INCIDENT, actions: [Permission::READ])
        @role_incident_read = create :role, permissions_list: [@permission_incident_read]
      end

      context "is set with read access" do
        before :each do
          @permission_role_specific_read = Permission.new(resource: Permission::ROLE, actions: [Permission::READ], role_ids: [@role_case_read.id])
          @role_role_specific_read = create :role, permissions_list: [@permission_role_specific_read], group_permission: Permission::GROUP
          @user1.role_ids = [@role_role_specific_read.id]
          @user1.save

          @ability = Ability.new @user1
        end

        it "allows user to read roles assigned to them" do
          expect(@ability).to authorize(:read, @role_case_read)
        end

        it "does not allow user to read roles not assigned to them" do
          expect(@ability).not_to authorize(:read, @role_tracing_request_read)
          expect(@ability).not_to authorize(:read, @role_incident_read)
        end

        it "does not allow user to edit roles assigned to them" do
          expect(@ability).not_to authorize(:edit, @role_case_read)
        end
      end

      context "is set with read write access" do
        before :each do
          @permission_role_specific_read_write = Permission.new(resource: Permission::ROLE, actions: [Permission::READ, Permission::WRITE],
                                                              role_ids: [@role_case_read.id, @role_incident_read.id])
          @role_role_specific_read_write = create :role, permissions_list: [@permission_role_specific_read_write], group_permission: Permission::GROUP
          @user1.role_ids = [@role_role_specific_read_write.id]
          @user1.save

          @ability = Ability.new @user1
        end

        it "allows user to read roles assigned to them" do
          expect(@ability).to authorize(:read, @role_case_read)
          expect(@ability).to authorize(:read, @role_incident_read)
        end

        it "does not allow user to read roles not assigned to them" do
          expect(@ability).not_to authorize(:read, @role_tracing_request_read)
        end

        it "allows user to edit roles assigned to them" do
          expect(@ability).to authorize(:edit, @role_case_read)
          expect(@ability).to authorize(:edit, @role_incident_read)
        end

        it "does not allow user to edit roles not assigned to them" do
          expect(@ability).not_to authorize(:edit, @role_tracing_request_read)
        end
      end

      context "is not set" do
        before :each do
          @permission_role_read_write = Permission.new(resource: Permission::ROLE, actions: [Permission::READ, Permission::WRITE])
          @role_non_role_specific_read_write = create :role, permissions_list: [@permission_role_read_write]
          @user1.role_ids = [@role_non_role_specific_read_write.id]
          @user1.save

          @ability = Ability.new @user1
        end

        it "allows user to read all roles" do
          expect(@ability).to authorize(:read, @role_case_read)
          expect(@ability).to authorize(:read, @role_tracing_request_read)
          expect(@ability).to authorize(:read, @role_incident_read)
        end

        it "allows user to edit all roles" do
          expect(@ability).to authorize(:edit, @role_case_read)
          expect(@ability).to authorize(:edit, @role_tracing_request_read)
          expect(@ability).to authorize(:edit, @role_incident_read)
        end
      end

      after do
        Role.all.each &:destroy
      end
    end

    context "when specifying which ROLES can be assigned" do
      before do
        Role.all.each &:destroy
        @permission_case_read = Permission.new(resource: Permission::CASE, actions: [Permission::READ])
        @role_case_read = create :role, permissions_list: [@permission_case_read]
        @permission_tracing_request_read = Permission.new(resource: Permission::CASE, actions: [Permission::READ])
        @role_tracing_request_read = create :role, permissions_list: [@permission_tracing_request_read]
        @permission_incident_read = Permission.new(resource: Permission::INCIDENT, actions: [Permission::READ])
        @role_incident_read = create :role, permissions_list: [@permission_incident_read]
        @permission_user_read_write = Permission.new(resource: Permission::USER, actions: [Permission::READ, Permission::WRITE])
      end

      context "and specifies 2 roles" do
        before :each do
          @permission_role_assign_2 = Permission.new(resource: Permission::ROLE, actions: [Permission::ASSIGN],
                                                     role_ids: [@role_case_read.id, @role_incident_read.id])
          @role_role_assign_2 = create :role, permissions_list: [@permission_user_read_write, @permission_role_assign_2],
                                              group_permission: Permission::GROUP
          @user1.role_ids = [@role_role_assign_2.id]
          @user1.save

          @ability = Ability.new @user1
        end

        it "allows user to assign the 2 roles specified" do
          expect(@ability).to authorize(:assign, @role_case_read)
          expect(@ability).to authorize(:assign, @role_incident_read)
        end

        it "does not allow user to assign the role not specified" do
          expect(@ability).not_to authorize(:assign, @role_tracing_request)
        end

        it "does not allow user to read any of the roles" do
          expect(@ability).not_to authorize(:read, @role_case_read)
          expect(@ability).not_to authorize(:read, @role_incident_read)
          expect(@ability).not_to authorize(:read, @role_tracing_request_read)
        end

        it "does not allow user to edit any of the roles" do
          expect(@ability).not_to authorize(:edit, @role_case_read)
          expect(@ability).not_to authorize(:edit, @role_incident_read)
          expect(@ability).not_to authorize(:edit, @role_tracing_request_read)
        end
      end

      context "and specifies ALL roles" do
        before :each do
          @permission_role_assign_all = Permission.new(resource: Permission::ROLE, actions: [Permission::ASSIGN])
          @role_role_assign_all = create :role, permissions_list: [@permission_user_read_write, @permission_role_assign_all],
                                              group_permission: Permission::GROUP
          @user1.role_ids = [@role_role_assign_all.id]
          @user1.save

          @ability = Ability.new @user1
        end

        it "allows user to assign all of the roles" do
          expect(@ability).to authorize(:assign, @role_case_read)
          expect(@ability).to authorize(:assign, @role_incident_read)
          expect(@ability).to authorize(:assign, @role_tracing_request_read)
          expect(@ability).to authorize(:assign, @role_role_assign_all)
        end
      end

      context "and specifies no roles" do
        before :each do
          @permission_role_read_write = Permission.new(resource: Permission::ROLE, actions: [Permission::READ, Permission::WRITE])
          @role_role_assign_none = create :role, permissions_list: [@permission_user_read_write, @permission_role_read_write],
                                                 group_permission: Permission::GROUP
          @user1.role_ids = [@role_role_assign_none.id]
          @user1.save

          @ability = Ability.new @user1
        end

        it "does not allow user to assign any of the roles" do
          expect(@ability).not_to authorize(:assign, @role_case_read)
          expect(@ability).not_to authorize(:assign, @role_incident_read)
          expect(@ability).not_to authorize(:assign, @role_tracing_request_read)
          expect(@ability).not_to authorize(:assign, @role_role_assign_none)
        end
      end

      context "and user has MANAGE permission on ROLE" do
        before :each do
          @permission_role_manage = Permission.new(resource: Permission::ROLE, actions: [Permission::MANAGE])
          @role_role_manage = create :role, permissions_list: [@permission_user_read_write, @permission_role_manage],
                                                 group_permission: Permission::GROUP
          @user1.role_ids = [@role_role_manage.id]
          @user1.save

          @ability = Ability.new @user1
        end

        it "allows user to assign all of the roles" do
          expect(@ability).to authorize(:assign, @role_case_read)
          expect(@ability).to authorize(:assign, @role_incident_read)
          expect(@ability).to authorize(:assign, @role_tracing_request_read)
          expect(@ability).to authorize(:assign, @role_role_manage)
        end
      end

      after do
        Role.all.each &:destroy
      end
    end
  end

  describe "Users" do
    before :each do
      @permission_user_read = Permission.new(resource: Permission::USER, actions: [Permission::READ])
      @permission_user_read_write = Permission.new(resource: Permission::USER, actions: [Permission::READ, Permission::WRITE])
    end

    it "allows a user with read permissions to manage their own user" do
      role = create :role, permissions_list: [@permission_user_read]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      expect(ability).to authorize(:read, @user1)
      expect(ability).to authorize(:write, @user1)
    end

    it "allows a user with no user permissions to manage their own user" do
      role = create :role, permissions_list: [@permission_case_read]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      expect(ability).to authorize(:read, @user1)
      expect(ability).to authorize(:write, @user1)
    end

    it "doesn't allow a user with no explicit 'user' permission to manage another user" do
      role = create :role, permissions_list: [@permission_case_read]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      expect(ability).not_to authorize(:read, @user2)
      expect(ability).not_to authorize(:write, @user2)
    end

    it "doesn't allow a user with no specified scope to edit another user" do
      role = create :role, permissions_list: [@permission_user_read]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      expect(ability).to_not authorize(:read, @user2)
      expect(ability).to_not authorize(:write, @user2)
    end

    it "allows a user with group scope to only edit another user in that group" do
      role = create :role, permissions_list: [@permission_user_read_write], group_permission: Permission::GROUP
      @user1.role_ids = [role.id]
      @user1.user_group_ids = ['test_group']
      @user1.save
      @user2.user_group_ids = ['test_group']
      @user2.save
      user3 = create :user, user_group_ids: ['other_test_group']

      ability = Ability.new @user1

      expect(ability).to authorize(:read, @user2)
      expect(ability).to authorize(:write, @user2)
      expect(ability).to_not authorize(:read, user3)
      expect(ability).to_not authorize(:write, user3)
    end

    it "allows viewing and editing of Groups, and Agencies if the 'user' permission is set along with 'read' and 'write'" do
      role = create :role, permissions_list: [@permission_user_read_write]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      [UserGroup, Agency].each do |resource|
        expect(ability).to authorize(:read, resource)
        expect(ability).to authorize(:write, resource)
      end
    end

    it "does not allow viewing and editing of Roles if the 'user' permission is set along with 'read' and 'write'" do
      role = create :role, permissions_list: [@permission_user_read_write]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      expect(ability).not_to authorize(:read, Role)
      expect(ability).not_to authorize(:write, Role)
    end

  end

  describe "Other resources" do
    it "allows viewing and editing of Metadata resources if that permission is set along with 'read' and 'write'" do
      permission_metadata = Permission.new(resource: Permission::METADATA, actions: [Permission::READ, Permission::WRITE])
      role = create :role, permissions_list: [permission_metadata]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      [FormSection, Field, Location, Lookup, PrimeroModule, PrimeroProgram].each do |resource|
        expect(ability).to authorize(:read, resource)
        expect(ability).to authorize(:write, resource)
      end
    end

    it "allows viewing and editing of System resources if that permission is set along with 'read' and 'write'" do
      permission_system = Permission.new(resource: Permission::SYSTEM, actions: [Permission::READ, Permission::WRITE])
      role = create :role, permissions_list: [permission_system]
      @user1.role_ids = [role.id]
      @user1.save

      ability = Ability.new @user1

      [ContactInformation, Device, Replication, SystemUsers].each do |resource|
        expect(ability).to authorize(:read, resource)
        expect(ability).to authorize(:write, resource)
      end
    end

  end

end
