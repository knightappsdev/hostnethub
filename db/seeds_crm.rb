# CRM Seed Data
puts "Creating CRM seed data..."

# Create sample leads
leads_data = [
  {
    first_name: "John", 
    last_name: "Smith", 
    email: "john.smith@example.com", 
    phone: "+44 20 7946 0958",
    company: "Tech Solutions Ltd", 
    website: "https://techsolutions.example.com",
    source: "website", 
    status: "new", 
    lifecycle_stage: "lead"
  },
  {
    first_name: "Sarah", 
    last_name: "Johnson", 
    email: "sarah.johnson@startupxyz.com", 
    phone: "+44 161 496 0321",
    company: "StartupXYZ", 
    website: "https://startupxyz.com",
    source: "referral", 
    status: "contacted", 
    lifecycle_stage: "marketing_qualified_lead"
  },
  {
    first_name: "Michael", 
    last_name: "Brown", 
    email: "m.brown@digitalagency.co.uk", 
    phone: "+44 113 496 0789",
    company: "Digital Marketing Agency", 
    website: "https://digitalagency.co.uk",
    source: "social_media", 
    status: "qualified", 
    lifecycle_stage: "sales_qualified_lead"
  },
  {
    first_name: "Emma", 
    last_name: "Davis", 
    email: "emma@creativestudio.org", 
    phone: "+44 121 496 0654",
    company: "Creative Studio", 
    website: "https://creativestudio.org",
    source: "advertising", 
    status: "in_progress", 
    lifecycle_stage: "lead"
  },
  {
    first_name: "David", 
    last_name: "Wilson", 
    email: "david.wilson@retailpro.com", 
    phone: "+44 141 496 0432",
    company: "RetailPro Solutions", 
    website: "https://retailpro.com",
    source: "website", 
    status: "qualified", 
    lifecycle_stage: "sales_qualified_lead"
  }
]

leads_data.each do |lead_data|
  lead = Lead.find_or_create_by(email: lead_data[:email]) do |l|
    l.assign_attributes(lead_data)
  end
  puts "Created lead: #{lead.full_name}"
end

# Convert some leads to contacts
qualified_leads = Lead.where(lifecycle_stage: ["marketing_qualified_lead", "sales_qualified_lead"]).limit(3)
qualified_leads.each do |lead|
  unless lead.contact
    contact = lead.convert_to_contact!
    puts "Converted lead #{lead.full_name} to contact"
    
    # Create a deal for this contact
    deal_data = case contact.company
    when "StartupXYZ"
      { name: "StartupXYZ Hosting Package", amount: 79.99, stage: "proposal", expected_close_date: 1.week.from_now }
    when "Digital Marketing Agency"
      { name: "Enterprise Hosting Solution", amount: 199.99, stage: "negotiation", expected_close_date: 3.days.from_now }
    when "RetailPro Solutions"
      { name: "E-commerce Hosting Platform", amount: 149.99, stage: "qualification", expected_close_date: 2.weeks.from_now }
    end
    
    if deal_data
      deal = Deal.create!(
        deal_data.merge(
          contact: contact,
          description: "Hosting package for #{contact.company}"
        )
      )
      puts "Created deal: #{deal.name}"
    end
  end
end

# Create sample activities
contacts = Contact.all
activities_data = [
  { activity_type: "call", title: "Discovery Call", description: "Initial requirements gathering call" },
  { activity_type: "email", title: "Proposal Sent", description: "Sent detailed hosting proposal with pricing" },
  { activity_type: "meeting", title: "Technical Discussion", description: "Discussed technical requirements and migration" },
  { activity_type: "call", title: "Follow-up Call", description: "Follow-up on proposal and answered questions" },
  { activity_type: "email", title: "Contract Sent", description: "Sent hosting contract for review" }
]

contacts.each_with_index do |contact, index|
  activity_data = activities_data[index % activities_data.length]
  
  Activity.create!(
    activity_data.merge(
      contact: contact,
      user_id: 1, # Assuming admin user exists
      activity_date: rand(1..30).days.ago
    )
  )
  puts "Created activity for #{contact.full_name}"
end

# Create sample tasks
leads_and_contacts = (Lead.all + Contact.all).uniq
task_templates = [
  { title: "Send welcome email", priority: "medium", status: "pending" },
  { title: "Schedule demo call", priority: "high", status: "pending" },
  { title: "Prepare hosting proposal", priority: "high", status: "in_progress" },
  { title: "Follow up on pricing", priority: "medium", status: "pending" },
  { title: "Technical requirements review", priority: "low", status: "completed" }
]

leads_and_contacts.each_with_index do |record, index|
  task_data = task_templates[index % task_templates.length]
  
  task_attributes = task_data.merge(
    user_id: 1, # Assuming admin user exists
    due_date: rand(1..14).days.from_now,
    description: "Task related to #{record.try(:full_name) || record.try(:display_name)}"
  )
  
  if record.is_a?(Lead)
    task_attributes[:lead] = record
  else
    task_attributes[:contact] = record
  end
  
  Task.create!(task_attributes)
  puts "Created task for #{record.try(:full_name) || record.try(:display_name)}"
end

# Create some notes
(Lead.all + Contact.all).each_with_index do |record, index|
  note_contents = [
    "Client expressed interest in our FREE marketing tools. This is a key differentiator.",
    "Mentioned they're currently using competitor service but unhappy with support.",
    "Budget approved for Professional plan. Ready to move forward.",
    "Needs migration assistance. Our FREE migration service will be valuable.",
    "Interested in email marketing features. Great fit for our FREE suite."
  ]
  
  note_content = note_contents[index % note_contents.length]
  
  note_attributes = {
    content: note_content,
    user_id: 1 # Assuming admin user exists
  }
  
  if record.is_a?(Lead)
    note_attributes[:lead] = record
  else
    note_attributes[:contact] = record
  end
  
  Note.create!(note_attributes)
  puts "Created note for #{record.try(:full_name) || record.try(:display_name)}"
end

# Create a few closed deals for revenue metrics
Contact.limit(2).each_with_index do |contact, index|
  deal_amounts = [299.99, 459.99]
  
  Deal.create!(
    name: "#{contact.company} - Closed Deal",
    description: "Successfully closed hosting deal",
    amount: deal_amounts[index],
    stage: "closed_won",
    probability: 100,
    contact: contact,
    expected_close_date: 1.month.ago,
    actual_close_date: 1.month.ago
  )
  puts "Created closed deal for #{contact.full_name}"
end

puts "\n✅ CRM seed data created successfully!"
puts "📊 Summary:"
puts "  - #{Lead.count} leads created"
puts "  - #{Contact.count} contacts created"
puts "  - #{Deal.count} deals created"
puts "  - #{Activity.count} activities logged"
puts "  - #{Task.count} tasks created"
puts "  - #{Note.count} notes added"
puts "\n🎯 Visit /admin/crm to see your CRM dashboard!"