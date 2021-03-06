require "test_helper"

describe TasksController do
  let (:task) {
    Task.create name: "sample task", description: "this is an example for a test",
    completed_at: Time.now + 5.days
  }
  
  # Tests for Wave 1
  describe "index" do
    it "can get the index path" do
      # Act
      get tasks_path
      
      # Assert
      must_respond_with :success
    end
    
    it "can get the root path" do
      # Act
      get root_path
      
      # Assert
      must_respond_with :success
    end
  end
  
  # Unskip these tests for Wave 2
  describe "show" do
    it "can get a valid task" do
      # skip
      # Act
      get task_path(task.id)
      
      # Assert
      must_respond_with :success
    end
    
    it "will redirect for an invalid task" do
      # skip
      # Act
      get task_path(-1)
      
      # Assert
      must_respond_with :redirect
    end
  end
  
  describe "new" do
    it "can get the new task page" do
      # skip
      
      # Act
      get new_task_path
      
      # Assert
      must_respond_with :success
    end
  end
  
  describe "create" do
    it "can create a new task" do
      # skip
      
      # Arrange
      task_hash = {
        task: {
          name: "new task",
          description: "new task description",
          completed_at: nil,
        },
      }

      # Act-Assert
      expect {
        post tasks_path, params: task_hash
      }.must_change "Task.count", 1

      new_task = Task.find_by(name: task_hash[:task][:name])
      expect(new_task.description).must_equal task_hash[:task][:description]
      expect(new_task.completed_at).must_equal task_hash[:task][:completed_at]

      must_respond_with :redirect
      must_redirect_to task_path(new_task.id)
    end
  end
  
  # Unskip and complete these tests for Wave 3
  describe "edit" do
    it "can get the edit page for an existing task" do

      get "/tasks/#{task.id}/edit"

      must_respond_with :success
    end
    
    it "will respond with redirect when attempting to edit a nonexistant task" do
      # skip
      get "/tasks/-1/edit"

      must_respond_with :redirect
    end
  end
  
  # Uncomment and complete these tests for Wave 3
  describe "update" do
    # Note:  If there was a way to fail to save the changes to a task, that would be a great
    #        thing to test.
    before do
      Task.create(name: 'Wash dishes', description: 'Clear sink', completed_at: nil)
    end
    let (:new_task_hash) {
      {
        task: {
            name: "Wash dishes",
            description: "Clear sink",
            completed_at: nil,
        },
      }
    }
    it "can update an existing task" do
      id = Task.first.id
      expect {
        patch task_path(id), params: new_task_hash
      }.wont_change "Task.count"

      must_redirect_to tasks_path

      update_task = Task.find_by(id: id)

      expect(update_task.name).must_equal new_task_hash[:task][:name]
      expect(update_task.description).must_equal new_task_hash[:task][:description]
      expect(update_task.completed_at).must_equal new_task_hash[:task][:completed_at]
    end
    
    it "will redirect to the root page if given an invalid id" do
      expect {
        patch task_path(-1), params: new_task_hash
      }.wont_change "Task.count"

      must_redirect_to tasks_path
    end
  end
  
  # Complete these tests for Wave 4
  describe "destroy" do
    it "destroys an existing task and redirects to the root page" do
      task = Task.create(name: 'Wash dishes', description: 'Clear sink', completed_at: nil)

      expect {
        delete task_path(task.id)
      }.must_change "Task.count", -1

      deleted_task = Task.find_by(name: 'Wash dishes')
      expect(deleted_task).must_be_nil

      must_respond_with :redirect
      must_redirect_to tasks_path
    end

    it "should not delete a book that doesn't exist and redirect to root path" do
      expect {
        delete task_path(-1)
      }.wont_change "Task.count"

      must_redirect_to tasks_path
    end
  end
  
  # Complete for Wave 4
  describe "toggle_complete" do
    it "can update a task as complete" do
      Task.create(name: 'Wash dishes', description: 'Clear sink', completed_at: nil)
      new_task_hash = {
          task: {
              name: "Wash dishes",
              description: "",
              completed_at: nil,
          },
      }
      task_to_complete = Task.find_by(completed_at: nil)

      #issues the put - act
      put task_complete_path(task_to_complete)
      completed_task = Task.find_by(id: task_to_complete.id)

      #assert
      expect(completed_task.completed_at).wont_be_nil
      expect(completed_task.completed_at).wont_equal ""
      must_redirect_to tasks_path
    end

    it "can change a completed task to an incomplete task" do
      Task.create(name: 'Wash dishes', description: 'Clear sink', completed_at: "2020-11-01 20:25:58")
      new_task_hash = {
          task: {
              name: "Wash dishes",
              description: "Clear sink",
              completed_at: "2020-11-01 20:25:58",
          },
      }
      completed_task = Task.find_by(completed_at: "2020-11-01 20:25:58")

      put task_incomplete_path(completed_task)
      incomplete_task = Task.find_by(id: completed_task.id)

      expect(incomplete_task.completed_at).must_equal ""
      must_redirect_to tasks_path
    end

    it "will respond with 404 if task to complete is nonexistant" do
      id = -1

      put task_complete_path(id)

      must_respond_with :not_found
    end
  end
end
