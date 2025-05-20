#include <iostream>
#include <string>

#include "example_my_resource.h"
#include "example_my_resource_next.h"

int main()
{
  std::cout << "Resource Original Name: " << example_my_resource.name << std::endl;
  std::cout << "Resource Size: " << example_my_resource.size << std::endl;
  std::cout << "Resource Content: " << std::endl;

  std::cout << std::string{
    reinterpret_cast<const char*>(example_my_resource.data), example_my_resource.size
  } << std::endl;

  std::cout << "\nResource Content (hex):" << std::endl;
  for (unsigned int i = 0; i < example_my_resource.size; ++i)
  {
    printf("%02x ", example_my_resource.data[i]);
    if ((i + 1) % 16 == 0)
    {
      printf("\n");
    }
  }
  printf("\n");

  std::cout << "Resource Original Name: " << example_my_resource_next.name << std::endl;
  std::cout << "Resource Size: " << example_my_resource_next.size << std::endl;
  std::cout << "Resource Content: " << std::endl;

  std::cout << std::string{
    reinterpret_cast<const char*>(example_my_resource_next.data), example_my_resource_next.size
  } << std::endl;

  std::cout << "\nResource Content (hex):" << std::endl;
  for (unsigned int i = 0; i < example_my_resource_next.size; ++i)
  {
    printf("%02x ", example_my_resource_next.data[i]);
    if ((i + 1) % 16 == 0)
    {
      printf("\n");
    }
  }
  printf("\n");

  return 0;
}
