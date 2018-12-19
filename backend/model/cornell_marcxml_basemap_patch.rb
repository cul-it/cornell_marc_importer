MarcXMLBaseMap.module_eval do

def cornell_citation_note(note_type, label = nil, template=nil, *tmpl_args)
    {
      :obj => :note_multipart,
      :rel => :notes,
      :map => {
        "self::datafield" => -> note, node {
          content =  node.inner_text

          label = label.call(node) if label.is_a?(Proc)

          note.send('label=', label) if label
          note.type = note_type
          note.subnotes = [{'jsonmodel_type' => 'note_text', 'content' => content}]
        }
      }
    }
  end

  def cornell_520(note_type, label = nil, template=nil, *tmpl_args)
    {
      :obj => :note_multipart,
      :rel => :notes,
      :map => {
        "self::datafield" => -> note, node {
          content =  node.inner_text

          label = label.call(node) if label.is_a?(Proc)

          note.send('label=', label) if label
          note.type = note_type
          note.subnotes = [{'jsonmodel_type' => 'note_text', 'content' => content}]
        }
      }
    }
  end




  def cornell_related_materials_note(note_type, label = nil, template=nil, *tmpl_args)
    {
      :obj => :note_multipart,
      :rel => :notes,
      :map => {
        "self::datafield" => -> note, node {
          content = template ? subfield_template(template, node, *tmpl_args) : node.inner_text
          content = content.gsub(/[#]/,', #')
          label = label.call(node) if label.is_a?(Proc)
          note.send('label=', label) if label
          note.type = note_type
          note.subnotes = [{'jsonmodel_type' => 'note_text', 'content' => content}]
        }
      }
    }
  end



  def agent_template
    {
      :rel => -> resource, agent {
        agent.publish = true
        resource[:linked_agents] << {
          # stashed value for the role
          :role => agent['_role'] || 'subject',
          :terms => agent['_terms'] || [],
          :relator => agent['_relator'],
          :ref => agent.uri
        }
      },
      :map => {
        "subfield[@code='e']" => -> agent, node {
          agent['_relator'] = node.inner_text.gsub(",","").gsub(".","")
        },
        "subfield[@code='4']" => -> agent, node {
          agent['_relator'] = node.inner_text unless agent['_relator']
        },
        "self::datafield" => {
          :defaults => {
            :name_order => 'direct',
            :source => 'ingest'
          }
        },
        "//datafield[@tag='046']" => {
          :obj => :date,
          :rel => :dates_of_existence,
          :map => {
            "self::datafield" => Proc.new {|date, node|
              date.expression = concatenate_subfields(['f', 'q', 's', 'g', 'r', 't'], node, '-', true)
              date.begin      = dates_of_existence_date_for(node, ['f', 'q', 's'])
              end_date        = dates_of_existence_date_for(node, ['g', 'r', 't'])
              if (date.begin and end_date) and (end_date.to_i > date.begin.to_i)
                date.end = end_date
              end
              date.date_type  = date.end ? 'range' : 'single'
            }
          },
          :defaults => {
            :label => 'existence',
            :date_type => 'single',
          }
        },
        "//datafield[@tag='678']" => {
          :obj => :note_bioghist,
          :rel => :notes,
          :map => {
            "self::datafield" => Proc.new {|note, node|
              note['subnotes'] << {
                'jsonmodel_type' => 'note_text',
                'content' => concatenate_subfields(['a', 'b', 'u'], node, ' ', true),
                'publish' => true,
              }
            }
          },
          :defaults => {
            :label => 'Biographical / Historical',
            :publish => true,
          }
        },
      }
    }
  end
end


