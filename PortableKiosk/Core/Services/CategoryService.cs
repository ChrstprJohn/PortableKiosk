using System.Collections.Generic;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class CategoryService
    {
        private readonly CategoryRepository categoryRepository =
            new CategoryRepository();

        public int Add(Category category)
        {
            return categoryRepository.Add(category);
        }

        public Category GetByID(int categoryID)
        {
            return categoryRepository.GetByID(categoryID);
        }

        public List<Category> GetAll()
        {
            return categoryRepository.GetAll();
        }

        public bool Update(Category category)
        {
            return categoryRepository.Update(category);
        }

        public bool Delete(int categoryID)
        {
            return categoryRepository.Delete(categoryID);
        }
    }
}
