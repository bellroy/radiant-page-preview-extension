require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class TestPage < Page
end

describe PreviewController do
  dataset :users, :home_page
  before(:each) do
    controller.stub! :verify_authenticity_token
    login_as :admin
  end

  describe 'show' do
    it 'should construct the page and process it' do
      controller.should_receive(:construct_page).and_return(mock('page', :process => true))
      post :show
    end
    
    # It doesn't make sense to preview a :post, as we can't specify the parameters
    # We're using :post to overcome the :get 65Kb limitation, but still want to
    # Page.process method to think it is a :get action (for logic like request.post?)
    it 'should override the request such that it is a get' do
      post :show
      request.method.should == :get
    end

    it 'should test that it does not modify page'
    it 'should test that it renders exceptions'
  end
  
  describe 'construct page' do
    before(:all) do
      PreviewController.class_eval { public :construct_page }
      Page.find_by_slug("/").parts.clear
    end
    before(:each) do
      part_parameters = HashWithIndifferentAccess.new('1' => {:name=> 'new part'})
      page_parameters = HashWithIndifferentAccess.new(:class_name => 'Page', :parts_attributes => part_parameters)
      query_parameters = HashWithIndifferentAccess.new(:page => page_parameters)

      controller.stub!(:params).and_return(query_parameters)
      controller.stub!(:request).and_return(request)
    end
    describe 'any page', :shared => true do
      it 'should contain parts created' do
        page = controller.construct_page

        page.parts.should_not be_empty
        page.parts.first.name.should == 'new part'
      end
      it 'should not retain parts marked for deletion' do
        controller.params[:page][:parts_attributes] = {'1' => {:name=> 'new part', :_delete => true}}
      
        controller.construct_page.parts.should be_empty 
      end
    end
    
    describe 'new child' do
      before do
        Page.stub!(:find).and_return @page
        request.stub!(:referer).and_return('/admin/pages/1/children/new')
      end
      it_should_behave_like "any page"
      it 'should not save any changes' do
        page_count = Page.count
        controller.construct_page
        Page.count.should == page_count
      end
      it 'should get the referrer' do
        request.should_receive(:referer).at_least(:once)
        controller.construct_page
      end
      it 'should retrieve the class_name from the params' do
        controller.params[:page].should_receive(:[]).with(:class_name).and_return 'page'
        controller.construct_page
      end
      it 'should create a new page' do
        controller.params[:page].stub!(:[]).with(:class_name).and_return 'test_page'
        controller.construct_page.class.should == TestPage
      end
      it 'should set get the parent from the referer' do
        request.stub!(:referer).and_return('/admin/pages/100/children/new')
        Page.should_receive(:find).with('100')
        controller.construct_page
      end
      it 'should assign the parent from the referer to the page' do
        parent = mock_model(Page)
        Page.stub!(:find).and_return parent
        controller.construct_page.parent.should == parent
      end
    end
    describe 'edit existing page' do
      before do
        request.stub!(:referer).and_return('/admin/pages/1/edit')
        controller.params[:page][:class_name] = "Page"
        @page = Page.find(:first)
        Page.stub!(:find).and_return @page
      end
      it_should_behave_like "any page"
      it 'should not save any changes' #TODO: Test this somehow
      it 'should have the original pages children' do
        #TODO: Make this text more explicitly test children
        controller.construct_page.children.should == @page.children
      end
      it 'should have the original pages parent' do
        #TODO: Make this text more explicitly test parent
        controller.construct_page.parent.should == @page.parent
      end
      it 'should change page class if it has changed' do
        controller.params[:page][:class_name] = "TestPage"  
        controller.construct_page.class.should == TestPage
      end
      it 'should have params attributes, not the existing page attributes' do
        @page.title = 'foo'
        controller.params[:page][:title] = 'bar'
        controller.construct_page.title.should == 'bar'
      end
    end
  end
end
