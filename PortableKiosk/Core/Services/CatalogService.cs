using System.Collections.Generic;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class CatalogService
    {
        private readonly CategoryRepository categoryRepository =
            new CategoryRepository();

        private readonly SizeRepository sizeRepository =
            new SizeRepository();

        public int AddCategory(Category category)
        {
            return categoryRepository.Add(category);
        }

        public List<Category> GetCategories()
        {
            return categoryRepository.GetAll();
        }

        public int AddSize(Size size)
        {
            return sizeRepository.Add(size);
        }

        public List<Size> GetSizes()
        {
            return sizeRepository.GetAll();
        }
    }
}
