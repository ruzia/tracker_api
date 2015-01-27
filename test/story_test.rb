require_relative 'minitest_helper'

describe TrackerApi::Resources::Story do
  let(:pt_user) { PT_USER_1 }
  let(:client) { TrackerApi::Client.new token: pt_user[:token] }
  let(:project_id) { pt_user[:project_id] }
  let(:project) { VCR.use_cassette('get project') { client.project(project_id) } }
  let(:story_id) { '66728004' }

  describe '.tasks' do
    it 'gets all tasks for this story' do
      VCR.use_cassette('get tasks', record: :new_episodes) do
        tasks = project.story(story_id).tasks

        tasks.wont_be_empty
        task = tasks.first
        task.must_be_instance_of TrackerApi::Resources::Task
      end
    end

    it 'gets all tasks even when the project_id is excluded from the story fields' do
      VCR.use_cassette('get tasks when stories filtered', record: :new_episodes) do
        stories = project.stories(with_state: 'unstarted', fields: 'name,story_type')
        stories.each do |story|
          tasks = story.tasks
          unless tasks.empty?
            task = tasks.first
            task.must_be_instance_of TrackerApi::Resources::Task
          end
        end
      end
    end
  end

  describe '.activity' do
    it 'gets all the activity for this story' do
      VCR.use_cassette('get activity', record: :new_episodes) do
        activity = project.story(story_id).activity

        activity.wont_be_empty
        event = activity.first
        event.must_be_instance_of TrackerApi::Resources::Activity
      end
    end
  end
end