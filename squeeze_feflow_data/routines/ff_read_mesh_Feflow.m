function [mesh_data] = ff_read_mesh_Feflow(filename)
file_id = fopen(filename);
fgetl(file_id);
line_data = fscanf(file_id,'%f',[8,1])';
last_node = line_data(5);
while (feof(file_id)==0) && last_node <= line_data(5)
last_node = line_data(5);
mesh_data(last_node,:)=line_data(2:4);
line_data = fscanf(file_id,'%f',[8,1]);

end
fclose('all');

end
