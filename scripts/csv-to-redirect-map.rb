# Given Mike's four-column CSV of old IDs,
# produce a yml file for mapping old to new.
while gets
  # This works for the data we have, but 
  # is NOT a general-purpose CSV parser.
  fedora, pretty, _artesia, ov3 = $_.strip.gsub('"','').split(',');
  next unless ov3 && ov3 != ''
  puts "\"/catalog/#{fedora}\": \"/catalog/#{ov3}\""
  puts "\"/catalog/#{pretty}\": \"/catalog/#{ov3}\"" if pretty != ''
end
