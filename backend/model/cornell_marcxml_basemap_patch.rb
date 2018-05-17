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

end


