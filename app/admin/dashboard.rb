ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Recent Projects" do
          Project.includes(:tasks).contract_projects.last(5).each do |project|
            panel "Project name: #{project.name}" do
              head 'Project tasks'
              hr
              ul do
                project.first_three_hot_tasks.each do |task|
                  li task.job_number
                end
                br
                li link_to 'More', admin_project_path(project)
              end
            end
            hr
          end
        end
      end

      column do
        if current_admin_user.pm?
          panel "Upcoming Vists" do
            table do
              thead do
                tr do
                  th 'Buyer Name'
                  th 'Action'
                end
              end

              tbody do
                Buyer.visits_due.each do |buyer|
                  tr do
                    td buyer
                    td link_to 'Change Status', edit_admin_buyer_path(buyer)
                  end
                end
              end
            end
          end
        else
          panel "Info" do
            para "Welcome Back."
          end
        end
      end
    end
  end # content
end
