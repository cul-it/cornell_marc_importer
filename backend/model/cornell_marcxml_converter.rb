
require_relative 'cornell_marcxml_basemap_patch'

class CornellMarcXMLConverter < MarcXMLConverter
	
	# Create the import type for marcxml agents 
	def self.import_types(show_hidden = false)
		[
			{
				:name => "MarcXML (Cornell)",
				:description => "Import MARC XML records for Cornell"
			}
		]
	end
	
	# Alter the information recieved from the resource 
	def initialize(input_file)
		super(input_file)
	end
		
	def self.instance_for(type, input_file)
		if type == "MarcXML (Cornell)"
			self.new(input_file)
		else
			nil
		end
	end
	
end

CornellMarcXMLConverter.configure do |config|

  config.doc_frag_nodes.uniq! 
  config["/record"][:obj] = :resource
  config["/record"][:map]["controlfield[@tag='001']"] = -> resource, node {
	bibid = node.inner_text
	if !resource.multi_identifiers.include?('bibid')
	  resource.multi_identifiers = [{'jsonmodel_type' => 'multi_identifier', 'identifier_type' => 'bibid', 'identifier_value' => bibid}]
	end
	}


	
	config["/record"][:map]["datafield[@tag='245']"] = -> resource, node {
		title = CornellMarcXMLConverter.subfield_template("{$a  }{$b }{[$h] }{$k , }{$n , }{$p , }{$s }{/ $c}", node)
    resource['title'] = title.gsub(/[,]$/,'')
	}

	config["/record"][:map]["datafield[@tag='520'][@ind1!='3' and @ind1!='8']"] = CornellMarcXMLConverter.cornell_520('scopecontent','Scope and content',"{$3: }{$a. }{($u) }{\n$b}")	
	config["/record"][:map]["datafield[@tag='520'][@ind1='8']"] = CornellMarcXMLConverter.cornell_520('scopecontent','Scope and content',"{$3: }{$a. }{($u) }{\n$b}")	


	config["/record"][:map]["datafield[@tag='544']"] =  CornellMarcXMLConverter.cornell_related_materials_note('relatedmaterial', 'Related Archival Materials', %q|
	{Indicator 1 @ind1--}{$3: }{$d. }
	{Address--$b, }{Country--$c. }{Provenance--$e. }{Note--$n}.|,
				{'ind1'=>{'1'=>'Associated Materials', '2'=>'Related Materials'}})

	config["/record"][:map]["datafield[@tag='524']"] = CornellMarcXMLConverter.cornell_citation_note('prefercite', 'Preferred Citation', "{$3: } {$a. } {$2}")

	


end